require 'spec_helper'

require 'ice_cube_extensions'
include IceCube
include IceCubeExtensions

describe Schedule, 'from_ical' do

  ical_string = <<-ICAL
DTSTART:20130314T201500Z
DTEND:20130314T201545Z
RRULE:FREQ=WEEKLY;BYDAY=TH;UNTIL=20130531T100000Z
ICAL


  def sorted_ical(ical)
    ical.split(/\n/).sort.map { |field|
      k, v = field.split(':')
      v = v.split(';').sort.join(';') if k == 'RRULE'

      "#{ k }:#{ v }"
    }.join("\n")
  end

  context "instantiation" do
    it "loads an ICAL string" do
      expect(Schedule.from_ical(ical_string)).to be_a(Schedule)
    end
  end

  context "daily frequency" do
    it 'matches simple daily' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.daily)

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles counts' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.daily.count(4))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles intervals' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.daily(4))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles intervals and counts' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.daily(4).count(10))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles exceptions' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.daily)
      schedule.add_exception_time(Time.now + 2.days)

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles until dates' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.daily.until(start_time + 15.days))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

  end

  context 'weekly frequency' do
    it 'matches simple weekly' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.weekly)

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles weekdays' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.weekly.day(:monday, :thursday))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles intervals' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.weekly(2))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles intervals and counts' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.weekly(2).count(4))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles intervals and counts on given weekdays' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.weekly(2).day(:monday, :wednesday).count(4))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end
  end

  context 'monthly frequency' do
    it 'matches simple monthly' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.monthly)

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles intervals' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.monthly(2))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles intervals and counts' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.monthly(2).count(5))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles intervals and counts on specific days' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.monthly(2).day_of_month(1, 15).count(5))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end
  end

  context 'yearly frequency' do
    it 'matches simple yearly' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.yearly)

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles intervals' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.yearly(2))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles a specific day' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.yearly.day_of_year(15))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles specific days' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.yearly.day_of_year(1, 15, -1))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles counts' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.yearly.count(5))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles specific months' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.yearly.month_of_year(:january, :december))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end

    it 'handles specific months and counts' do
      start_time = Time.now

      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule(Rule.yearly.month_of_year(:january, :december).count(15))

      ical = schedule.to_ical
      expect(sorted_ical(Schedule.from_ical(ical).to_ical)).to eq(sorted_ical(ical))
    end
  end
end
