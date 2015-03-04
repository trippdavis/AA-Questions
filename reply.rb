require_relative 'questions_db'

class Reply < QModel

  def self.all
    results = QDB.instance.execute('SELECT * FROM replies')
    results.map{|result| Reply.new(result)}
  end

  def self.create(options)
    reply = Reply.new(options)
    reply.save
    reply
  end


  def self.find_by_id(id)
    results = QDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    results.map{|result| Reply.new(result)}
  end

  def self.find_by_user_id(user_id)
    results = QDB.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL

    results.map{|result| Reply.new(result)}
  end

  def self.find_by_question_id(question_id)
    results = QDB.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    results.map{|result| Reply.new(result)}
  end

  # def save
  #   if @id
  #     QDB.instance.execute(<<-SQL, @question_id, @parent_id, @author_id, @body, @id)
  #       UPDATE
  #         replies
  #       SET
  #         question_id = ?, parent_id = ?, author_id = ?, body = ?
  #       WHERE
  #         id = ?
  #     SQL
  #   else
  #     QDB.instance.execute(<<-SQL, @question_id, @parent_id, @author_id, @body)
  #       INSERT INTO
  #         replies(question_id, parent_id, author_id, body)
  #       VALUES
  #         ( ?, ?, ?, ?)
  #     SQL
  #
  #     @id = QDB.instance.last_insert_row_id
  #   end
  # end

  def author
    User.find_by_id(@author_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_id)
  end

  def child_replies
    Reply.all.select do |reply|
      reply.parent_id = @id
    end
  end

end
