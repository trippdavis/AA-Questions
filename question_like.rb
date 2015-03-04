require_relative 'questions_db'

class QuestionLike < QModel

  # def self.all
  #   results = QDB.instance.execute('SELECT * FROM question_likes')
  #   results.map{|result| QuestionLike.new(result)}
  # end
  #
  # def self.create(options)
  #   like = QuestionLike.new(options)
  #   like.save
  #   like
  # end
  #
  # def self.find_by_id(id)
  #   results = QDB.instance.execute(<<-SQL, id)
  #     SELECT
  #       *
  #     FROM
  #       question_likes
  #     WHERE
  #       id = ?
  #   SQL
  #
  #   results.map{|result| QuestionLike.new(result)}
  # end

  def self.likers_for_question_id(question_id)
    results = QDB.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      INNER JOIN
        question_likes ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL

    results.map {|result| User.new(result)}
  end

  def self.num_likes_for_question_id(question_id)
    results = QDB.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*) count
      FROM
        question_likes
      WHERE
        question_id = ?
    SQL

    return results.first['count']
  end

  def self.liked_questions_for_user_id(user_id)
    results = QDB.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      INNER JOIN
        question_likes ON questions.id = question_likes. question_id
      WHERE
        question_likes.user_id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def self.most_liked_questions(n)
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
            question_likes
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
  #         question_likes
  #       SET
  #         user_id = ?, question_id = ?
  #       WHERE
  #         id = ?
  #     SQL
  #   else
  #     QDB.instance.execute(<<-SQL, @user_id, @question_id)
  #       INSERT INTO
  #         question_likes(user_id, question_id)
  #       VALUES
  #         ( ?, ?)
  #     SQL
  #
  #     @id = QDB.instance.last_insert_row_id
  #   end
  # end
end
