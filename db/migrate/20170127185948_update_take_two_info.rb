class UpdateTakeTwoInfo < ActiveRecord::Migration
  def up
    program = KpccProgram.where(slug: 'take-two').first
    program.host        = "A Martínez"
    program.airtime     = "Weekdays 9 to 10 a.m."
    program.description = "Join Take Two each weekday at 9 AM where we’ll translate the day’s headlines for Southern California, making sense of the news and cultural events that people are talking about. Find us on 89.3 KPCC, hosted by A Martinez." 
    program.save
  end
  def down
    program = KpccProgram.where(slug: 'take-two').first
    program.host        = "Alex Cohen & A Martínez"
    program.airtime     = "Weekdays 9 to 11 a.m."
    program.description = "Take Two, exclusively on 89.3 KPCC, 89.1 KUOR and 90.3 KVLA in southern California, and on 88.9 KNPR in Las Vegas, captures the spirit of the West in a conversational, informal, witty style and examines the cultural issues people are buzzing about. "
    program.save
  end
end
