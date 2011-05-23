require 'rubygems'
require 'dbi'
require 'dbi/utils'
require 'notes_mailer'


class SQLRunner
  def initialize(conf)
    # --------------------------------------------------------------------------------------
    # DB-settings
    # --------------------------------------------------------------------------------------
    @db_id = conf[:db_name]
    @db_user = conf[:db_user]
    @db_password = conf[:db_password]

    # --------------------------------------------------------------------------------------
    # SQL-settings
    # --------------------------------------------------------------------------------------
    @path_to_sql_files = conf[:path_to_sql_files]

    # --------------------------------------------------------------------------------------
    # Mailsettings
    # --------------------------------------------------------------------------------------
    @notes_server = conf[:notes_server]
    @notes_db = conf[:notes_db]
    @notes_user = conf[:notes_user]
    @notes_password = conf[:notes_password]

    @mail_to = conf[:mail_to]

    # --------------------------------------------------------------------------------------
    # Other settings
    # --------------------------------------------------------------------------------------
    @dry_run = conf[:dry_run]
    @mock_win32ole = conf[:mock_win32ole]
    @verbose = conf[:verbose]

  end

  def run
    error_text = execute_sql
    if @mail_to
      send_mail({:to     => @mail_to,
                      :body => error_text,
                      :db    => @notes_db,
                      :adress => @notes_server,
                      :user_name      =>@notes_user,
                      :password        =>@notes_password,
                      :mock_win32ole => @mock_win32ole,
                      :logger => @verbose,
                      :debug => @verbose})
    else
      puts error_text
    end
  end

  def execute_sql
    # --------------------------------------------------------------------------------------
    # Execute SQL statements
    # --------------------------------------------------------------------------------------
    error_text = ''
    error_text << " -------------- DRY RUN --------------\n" if @dry_run
    DBI.connect('DBI:ODBC:'+@db_id,  @db_user, @db_password) do |dbh|
      dbh['AutoCommit']=false
      rbfiles = File.join(@path_to_sql_files+"**", "*.sql")
      Dir.glob(rbfiles).each do |file|
        begin
          File.open(file) do |f|
          sql = f.readlines.join("\n").to_s
          if @dry_run
             error_text << "File: #{file}\n"
             print '.'
          else
            begin
              sth = dbh.execute(sql)
              header = sth.column_names
              rows = []
              while (row = sth.fetch)
                rows << row.to_a
              end
              sth.finish
              if rows.size > 0
                error_text << "\nFile: #{file} (Anzahl Datensaetze: #{rows.size.to_s}).\n"
                DBI::Utils::TableFormatter.ascii(header,rows, :left, :left, 2,1, nil, error_text)
                print 'E'
              else
                print '.'
              end
              dbh.rollback()
            end
          end
         end
        rescue => detail
          print 'F'
          error_text << "File: #{file} \n"
          error_text << detail.backtrace.join("\n")
        end
      end
    end
    error_text
  end

  def send_mail(opts)
    # --------------------------------------------------------------------------------------
    # Mail Settings
    # --------------------------------------------------------------------------------------
    Mail.defaults do
       delivery_method(Mail::NotesMailer, opts)
    end

    # --------------------------------------------------------------------------------------
    # Mail Versand
    # --------------------------------------------------------------------------------------
    Mail.deliver do
      to opts[:to]
      from 'SQLRunner (c) 2011 Elias Kugler'
      subject (opts[:subject] || 'Fehler bei Pruefselects')
      body "Bitte beachten: \n"+opts[:body]
      #add_file File.join(Dir.pwd, 'test_notes_mailer.rb')
    end
  end
end