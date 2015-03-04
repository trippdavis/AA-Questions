require_relative 'questions_db'

class Hash
  # Return a hash that includes everything but the given keys. This is useful for
  # limiting a set of parameters to everything but a few known toggles:
  #
  #   @person.update_attributes(params[:person].except(:admin))
  #
  # If the receiver responds to +convert_key+, the method is called on each of the
  # arguments. This allows +except+ to play nice with hashes with indifferent access
  # for instance:
  #
  #   {:a => 1}.with_indifferent_access.except(:a)  # => {}
  #   {:a => 1}.with_indifferent_access.except("a") # => {}
  #
  def except(*keys)
    dup.except!(*keys)
  end

  # Replaces the hash without the given keys.
  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end
end

class QuestionFollow < QModel

  # def self.all
  #   results = QDB.instance.execute('SELECT * FROM question_follows')
  #   results.map{|result| QuestionFollow.new(result)}
  # end
  #
  # def self.create(options)
  #   follow = QuestionFollow.new(options)
  #   follow.save
  #   follow
  # end
  #
  # def self.find_by_id(id)
  #   results = QDB.instance.execute(<<-SQL, id)
  #     SELECT
  #       *
  #     FROM
  #       question_follows
  #     WHERE
  #       id = ?
  #   SQL
  #
  #   results.map{|result| QuestionFollow.new(result)}
  # end

  def self.followers_for_question_id(question_id)
    results = QDB.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      INNER JOIN
        question_follows ON users.id = question_follows.user_id
      WHERE
        question_follows.question_id = ?
    SQL
    results.map { |result| User.new(result) }
  end

  def self.followed_questions_for_user_id(user_id)
    results = QDB.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      INNER JOIN
        question_follows ON questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL
    results.map { |result| Question.new(result) }
  end

  def self.most_followed_questions(n)
    results = QDB.instance.execute(<<-SQL, n)
      SELECT
        questions.*, ordered.count
      FROM
        questions
      INNER JOIN
        (
          SELECT
            question_id, COUNT(*) count
          FROM
            question_follows
          GROUP BY
            question_id
          ORDER BY
            COUNT(*) DESC
          LIMIT
            ?
        ) AS ordered ON ordered.question_id = id
    SQL

    results.map do |result|
       [Question.new(result.except('count')), result['count']]
    end
  end

  # def save
  #   if @id
  #     QDB.instance.execute(<<-SQL, @user_id, @question_id, @id)
  #       UPDATE
  #         question_follows
  #       SET
  #         user_id = ?, question_id = ?
  #       WHERE
  #         id = ?
  #     SQL
  #   else
  #     QDB.instance.execute(<<-SQL, @user_id, @question_id)
  #       INSERT INTO
  #         question_follows(user_id, question_id)
  #       VALUES
  #         ( ?, ?)
  #     SQL
  #
  #     @id = QDB.instance.last_insert_row_id
  #   end
  # end
end
