require_relative 'questions_db'

class Question < QModel

  # def self.all
  #   results = QDB.instance.execute('SELECT * FROM questions')
  #   results.map{|result| Question.new(result)}
  # end
  #
  # def self.create(options)
  #   question = Question.new(options)
  #   question.save
  #   question
  # end
  #
  # def self.find_by_id(id)
  #   results = QDB.instance.execute(<<-SQL, id)
  #     SELECT
  #       *
  #     FROM
  #       questions
  #     WHERE
  #       id = ?
  #   SQL
  #
  #   results.map{|result| Question.new(result)}
  # end

  # def self.find_by_author_id(author_id)
  #   results = QDB.instance.execute(<<-SQL, author_id)
  #     SELECT
  #       *
  #     FROM
  #       questions
  #     WHERE
  #       author_id = ?
  #   SQL
  #
  #   results.map{|result| Question.new(result)}
  # end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionFollow.most_liked_questions(n)
  end

  # def save
  #   if @id
  #     QDB.instance.execute(<<-SQL, @title, @author_id, @body, @id)
  #       UPDATE
  #         questions
  #       SET
  #         title = ?, author_id = ?, body = ?
  #       WHERE
  #         id = ?
  #     SQL
  #   else
  #     QDB.instance.execute(<<-SQL, @title, @author_id, @body)
  #       INSERT INTO
  #         questions(title, author_id, body)
  #       VALUES
  #         ( ?, ?, ?)
  #     SQL
  #
  #     @id = QDB.instance.last_insert_row_id
  #   end
  # end

  def author
    User.find_by_id(@author_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

end
