require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_number(phone_number)
  phone_number.gsub!(/[^0-9]/,"")

  unless phone_number.length ==10
      if phone_number.length == 11 && phone_number[0] == "1"
          phone_number = phone_number[1..-1]
      else
       phone_number = "0000000000"
      end
  end

  phone_number.split("")
      .insert(0,"(")
      .insert(4,")")
      .insert(8,"-")
      .join("")
end

DAY_OF_THE_WEEK = {0=>"Sunday",
  1=>"Monday",
  2=>"Tuesday",
  3=>"Wednesday",
  4=>"Thursday",
  5=>"Friday",
  6=>"Saturday"}

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter


contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end


contents.each do |row|
  phone_number = row[:homephone]
  clean_phone_number(phone_number)
end

hours_count = Hash.new(0)
day_count = Hash.new(0)
contents.each do |row|
    reg_date = row[:regdate]
    day_time = Time.strptime(reg_date, "%Y/%d/%m %H:%M")
    hour = day_time.hour
    hours_count[hour] += 1
    day = day_time.wday
    day_count[day] += 1
end
h = hours_count.sort_by{|key,value| value}[-1].flatten[0]
puts "Busiest hour is: #{h}:00"

d = day_count.sort_by{|key,value| value}[-1].flatten[0]
puts "Busiest day of the week is: #{DAY_OF_THE_WEEK[d]}"