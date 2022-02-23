require 'csv'


contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
)

contents.each do |row|
    phone_number = row[:homephone]
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
