require_relative 'questions_db'

class User < QModel

  def self.all
    results = QDB.instance.execute('SELECT * FROM users')
    results.map{|result| User.new(result)}
  end

  def self.create(options)
    user = User.new(options)
    user.save
    user
  end

  def self.find_by_id(id)
    results = QDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    results.map{|result| User.new(result)}
  end

  def self.find_by_name(fname, lname)
    results = QDB.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL

    results.map{|result| User.new(result)}
  end

  # def save
  #   if @id
  #     QDB.instance.execute(<<-SQL, @fname, @lname, @id)
  #       UPDATE
  #         users
  #       SET
  #         fname = ?, lname = ?
  #       WHERE
  #         id = ?
  #     SQL
  #   else
  #     QDB.instance.execute(<<-SQL, @fname, @lname)
  #       INSERT INTO
  #         users(fname, lname)
  #       VALUES
  #         ( ?, ?)
  #     SQL
  #
  #     @id = QDB.instance.last_insert_row_id
  #   end
  # end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    result = QDB.instance.execute(<<-SQL, uid: @id)
      SELECT
        CAST(COUNT(ql.id) AS FLOAT) / COUNT(DISTINCT(q.id)) avg_karma
      FROM
        questions q
      LEFT OUTER JOIN
        question_likes ql ON ql.question_id = q.id
      WHERE
        q.author_id = :uid
    SQL

    result.first['avg_karma'] ? result.first['avg_karma'] : 0
  end

end
