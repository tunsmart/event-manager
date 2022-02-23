require 'time'
require 'csv'

DAY_OF_THE_WEEK = {0=>"Sunday",
    1=>"Monday",
    2=>"Tuesday",
    3=>"Wednesday",
    4=>"Thursday",
    5=>"Friday",
    6=>"Saturday"}

contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
)

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
puts "Busiest Hour is: #{h}:00"

d = day_count.sort_by{|key,value| value}[-1].flatten[0]
puts "Busiest day of the week is: #{DAY_OF_THE_WEEK[d]}"
