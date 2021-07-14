require 'rubygems'
require 'sqlite3'
require 'bundler/setup'
require 'pony'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, "sqlite3:barbershop.db"

class Client < ActiveRecord::Base
	validates :name, presence: true
	validates :phone, presence: true
	validates :datestamp, presence: true 
	validates :barber, presence: true

end

class Barbers < ActiveRecord::Base
end

class Contact < ActiveRecord::Base
	validates :name, presence: true
	validates :email, presence: true
	validates :message, presence: true 
end

before do
	@barbers = Barbers.all
end

configure do
	enable :sessions
	
end

helpers do
	def username
		if   session[:identity] == 'admin' && session[:password] == 'secret'
			"Вход выполнен"
		else
			"Выполните вход"
		end	
end

before '/secure/*' do
	unless session[:identity] == 'admin' && session[:password] == 'secret' 
	  session[:previous_url] = request.path
	  @error = 'Извините, просмотр служебной информации только для администрации'
	  halt erb(:login_form)
	end
 end

 
 get '/login/form' do
	erb :login_form
end

get '/secure/place' do
	erb :'/secure/place'
end

post '/login/attempt' do
	session[:identity] = params['username']
	session[:password] = params['password']
	where_user_came_from = session[:previous_url] || '/'
	redirect to where_user_came_from
end



get '/logout' do
	session.delete(:identity)
	erb "<div class='alert alert-message'>Вы вышли</div>"
end



get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
	erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/about' do
	erb :about
end

get '/visit' do
	@visit = Client.new
	erb :visit
end

post '/visit' do 
	
	@visit = Client.new params[:client]
	@visit.save
	
	if @visit.save
		erb "Уважаемый #{@visit.name}, #{@visit.barber} будет ждать Вас #{@visit.datestamp}"
	else
		@error = @visit.errors.full_messages.first
		erb :visit
	end
end	

	

	end

get '/contacts' do
	@contact = Contact.new
	erb :contacts
end

post '/contacts' do
	
	@contact = Contact.new params[:contact]
	@contact.save
  
	if @contact.save
		Pony.mail(:to => '3374555@mail.ru', 
				  :from => "#{@contact.email}", 
				  :subject => "Сообщение от #{@contact.name}", 
				  :body => "#{@contact.message}",   
				  :via_options => {
								:address              => 'smtp.gmail.com',
								:port                 => '587',
								:enable_starttls_auto => true,
								:user_name            => 'eo0065110@gmail.com',
								:password             => 'eo0065110_google',
								:authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
								:domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
	 							}
				)		
		@title = "Успешно!"
			@message = "Ваше сообщение отправлено и будет обработано в ближайшее время!"
			erb :message
	else
		@error = @contact.errors.full_messages.first
		erb :contacts
	end
		  

end 


  