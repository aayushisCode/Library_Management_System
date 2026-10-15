require "securerandom"


module InputHandler
  def read_input(prompt)
    print prompt
    input = gets
    exit if input.nil?
    input.strip
  end

  def read_non_blank(prompt)
    loop do
      value = read_input(prompt)

      return value unless value.empty?

      puts "Input cannot be blank."
    end
  end

  def read_positive_integer(prompt)
    loop do
      value = read_input(prompt)

      # \A means start of string
      # \d+ means one or more digits
      # \z means end of string
      # positive? checks whether the number is greater than zero
      if value.match?(/\A\d+\z/) && value.to_i.positive?
        return value.to_i
      else
        puts "Please enter a positive integer."
      end
    end
  end

  def valid_email?(email)
    email.match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
  end

	def read_valid_email
  	loop do
    	email = read_non_blank("Enter member email: ").downcase

    	unless valid_email?(email)
      	puts "Please enter a valid email address."
      	next
    	end

    	if email_exists?(email)
      	puts "Email already exists. Please use another email."
      	next
    	end

    	return email
  	end
	end
end



class Library
	 	include InputHandler

    MAX_ISSUED_BOOKS = 3

    def initialize
        @books=[]
        @members=[]
        @issued_books=[]
    end

    def display_menu
        loop do
            puts "\n =========Library Management System========"
            puts  "1. Add Book "
            puts  "2. View All Books"
            puts  "3. Search Book"
            puts  "4. Register Member"
            puts  "5. View All Members"
            puts  "6. Issue Book"
            puts  "7. Return Book"
            puts  "8. View Issued Books"
            puts  "9. View Library Summary"
            puts  "10. Exit"
            
            choice = read_input("Enter your choice:")

            case choice
            when "1" then add_book
            when "2" then view_all_books
            when "3" then search_book
            when "4" then register_member
            when "5" then view_all_members
            when "6" then issue_book
            when "7" then return_book
            when "8" then view_issued_books
            when "9" then view_Library_summary
            when "10" then puts "Thank you for visiting the Library!"
                break
            else puts "Invalid choice. Please enter a valid number between 1 to 10."
            end
        end
    end

    def add_book
        puts "\n ======Adding Book======"
        # id = read_non_blank("Enter BookID: ")
        # if find_book(id)
        #     puts "Book with ID #{id} already exists."
        #     return
        # end
        title = read_non_blank("Enter a book Title: ")
        author = read_non_blank("Enter Author Name: ")
        category = read_non_blank("Enter Book Category: ")
        copies = read_positive_integer("Enter Number of Copies: ")

        @books << {
            id: SecureRandom.random_number(1000..9999),
            title: title,
            author: author,
            category: category,
            total_copies: copies,
            available_copies: copies,
        }
        puts "Book added successfully!!"
        puts "BookId for  #{@books.last[:id]}"


    end

    def view_all_books
        puts "\n ======All Books======"
        if @books.empty?
            puts "No book available "
            return
        end

        #available
        @books.each { |book| puts "Title: #{book[:title]}, Author: #{book[:author]}, Category: #{book[:category]}, Available Copies: #{book[:available_copies]}, ID: #{book[:id]}" }

    end

    def search_book
        if @books.empty? 
            puts " No book avaiable"
            return
        end
        puts "1. Search by ID"
        puts "2. Search by Title"
        puts  "3.Search by Author"

        choice = read_input("Enter your choice here: ")
        value = read_non_blank("Enter your search query: ")

        results = case choice
        when "1" then @books.select { |b| b[:id].to_s == value }
        when "2" then @books.select { |b| b[:title].downcase.include?(value.downcase) }
        when "3" then @books.select { |b| b[:author].downcase.include?(value.downcase) }
        else
            puts "Invalid choice."
            return
        end
        if results.empty?
            puts "Book not found"
        else 
            results.each { |b| puts "Title: #{b[:title]}, Author: #{b[:author]}, Category: #{b[:category]}, ID: #{b[:id]}"}
            puts "============================"
        end
    end


    def register_member
        puts "\n ===Register Member====="
        # mem_id = read_non_blank("Enter MemberID: ")
        # if find_member(mem_id)
        #     puts "Member with ID #{mem_id} already exists"
        #     return
        # end
        name = read_non_blank("Enter Member name: ")
        email = read_valid_email

        @members << {
            id: SecureRandom.random_number(1000..9999),
            name: name,
            email: email
        }
        puts "Member successfully registered !!"
        puts "MemberId for  #{@members.last[:id]}"

    end


    def view_all_members
        puts "\n =======All Members======="
        if @members.empty?
            puts "No member registered yet"
            return
        end
        @members.each { |m| puts "MemberID: #{m[:id]}, MemberName: #{m[:name]}, MemberEmail: #{m[:email]}"}

    end


    def issue_book
        book_id = read_non_blank("Enter BookID: ")
        book = find_book(book_id)

        unless book
            puts " Sorry! Book not found"
            return
        end
        
            
        member_id = read_non_blank("Enter MemberID:")
        member = find_member(member_id)

        unless member
            puts "Sorry! Member not found"
            
            return
        end

        #not avaiable
        if book[:available_copies ] <=0
            puts " sorry no books available for issue"
            return
        end
        #-1 if book issued
        # book[:available_copies] -= 1
        # @issued_books[book_id] ||=[]

        active_issue = @issued_books.select {|issue| issue[:member_id].to_s == member_id && issue[:active]}
        
        if active_issue.size >= MAX_ISSUED_BOOKS
            puts "Sorry! Member has already issued maximum number of books."
            return
        end

        already_issued = active_issue.any?{ |issue| issue[:book_id].to_s == book_id}
        if already_issued
            puts "Sorry! Member has already issued this book."
            return
        end

        @issued_books << {
            book_id: book_id,
            member_id: member_id,
            active: true
        }
        book[:available_copies] -= 1
        puts "Book issued successfully!"
        puts "Available copies of the book: #{book[:available_copies]}"
        

    end

    def return_book
        puts "\n ============Return Book============"
        book_id = read_non_blank("Enter BookId:")
        book = @books.find {|b| b[:id].to_s == book_id}

        member_id = read_non_blank("Enter MemberId:")
        member = @members.find {|m| m[:id].to_s == member_id}

        unless book && member
          puts "Invalid book or member ID."
          return
        end
        issue = @issued_books.find { |issue| issue[:book_id].to_s == book_id && issue[:member_id].to_s == member_id && issue[:active] }
          
        if issue
            issue[:active] = false
            book[:available_copies] += 1
            puts "Book returned successfully!"
            puts "Available copies of the book: #{book[:available_copies]}"
        else
            puts "Book not found in issued books."
        end
    end

    def view_issued_books
        puts "\n ============Issued Books============"
        
        active_issues = @issued_books.select { |issue| issue[:active] }
        if active_issues.empty?
          puts " No books currently issued."
          return
        end

        active_issues.each { |issue| puts " BookID : #{issue[:book_id].to_s},
        MemberID: #{issue[:member_id].to_s }"

        next unless book && member
          
          puts "BookID: #{book[:id]}, MemberID: #{member[:id]}, 
          Issued to MemberID: #{member[:id]},MemberName: #{member[:name]}"}
			
    
    end


    def view_Library_summary
			puts "\n ============Library Summary=============="
			total_titles = @books.size
			total_copies = @books.sum { |b| b[:available_copies] }
			total_available_copies = @books.sum { |b| b[:available_copies] }
			registered_member=  @members.size
			currently_issued_books = @issued_books.count {|issue| issue[:active] }

			summary = {
				total_book_titles: total_titles,
				total_copies: total_copies,
				available_copies: total_available_copies,
				registered_members: registered_member,
				currently_issued_books: currently_issued_books
			}

			summary.each { |key,value| 
		puts "#{key.to_s.tr('_',' ').capitalize}: #{value}"}
    end
#=================================================================================================
private

  def email_exists?(email)
    @members.any? do |member|
      member[:email].casecmp?(email)
    end
  end
end


library = Library.new
library.display_menu
