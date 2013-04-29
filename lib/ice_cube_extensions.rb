module IceCubeExtensions
  include IceCube

  class IceCube::Schedule

    def self.from_ical(ical)
      return nil if ical.nil? or ical.empty?

      schedule = IceCube::Schedule.new

      ical.split(/\n/).each do |field|
        name, value = field.split(":")

        day_names = {
          'MO' => :monday,
          'TU' => :tuesday,
          'WE' => :wednesday,
          'TH' => :thursday,
          'FR' => :friday,
          'SA' => :saturday,
          'SU' => :sunday,
        }

        month_names = [
          nil,
          :january,
          :february,
          :march,
          :april,
          :may,
          :june,
          :july,
          :august,
          :september,
          :october,
          :november,
          :december
        ]

        case name.sub(/;.*/, '')
        when "DTSTART"
          schedule.start_time = Time.parse(value)
        when "DTEND"
          schedule.end_time = Time.parse(value)
        when "EXDATE"
          schedule.add_exception_time(Time.parse(value))
        when "RRULE"
          rrule = {}
          value.split(';').each do |frag|
            k, v = frag.split('=')
            rrule[k] = v
          end

          rule = IceCube::Rule.send(rrule['FREQ'].downcase)

          # common to any freq
          unless rrule['INTERVAL'].nil?
            rule.interval(rrule['INTERVAL'].to_i)
          end
          unless rrule['COUNT'].nil?
            rule.count(rrule['COUNT'].to_i)
          end
          unless rrule['UNTIL'].nil?
            rule.until(Time.parse(rrule['UNTIL']))
          end

          if rrule['FREQ'] == 'DAILY'
          end

          if rrule['FREQ'] == 'WEEKLY'
            unless rrule['BYDAY'].nil?
              days = rrule['BYDAY'].split(',').collect{ |day| day_names[day] }.flatten

              rule.send('day', *days)
            end
          end

          if rrule['FREQ'] == 'MONTHLY'
            unless rrule['BYMONTHDAY'].nil?
              days = rrule['BYMONTHDAY'].split(',')
              rule.send('day_of_month', *days)
            end
            unless rrule['BYDAY'].nil?
              days = {}
              rrule['BYDAY'].split(',').each do |day|
                weekday = day_names[day[1,2]]
                days[weekday] = [] unless days.has_key?(weekday)
                days[weekday]<< day[0]
              end

              rule.send('day_of_week', *days)
            end
          end

          if rrule['FREQ'] == 'YEARLY'
            unless rrule['BYMONTH'].nil?
              months = rrule['BYMONTH'].split(',').map { |m| month_names[m.to_i] }
              rule.send('month_of_year', *months)
            end

            unless rrule['BYYEARDAY'].nil?
              days = rrule['BYYEARDAY'].split(',')
              rule.send('day_of_year', *days)
            end
          end

          schedule.add_recurrence_rule(rule)
        end
      end

      schedule
    end
  end

  class IceCube::ValidatedRule

    def to_ical
      builder = IceCube::IcalBuilder.new
      @validations.each do |name, validations|
        validations.each do |validation|
          validation.build_ical(builder)
        end
      end
      builder.to_s
        .gsub('YEARLY,YEARLY', 'YEARLY')
        .gsub('MONTHLY,MONTHLY', 'MONTHLY')
        .gsub('WEEKLY,WEEKLY', 'WEEKLY')
        .gsub('DAILY,DAILY', 'DAILY')
    end

  end

end
