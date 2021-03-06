# frozen_string_literal: true

module Montrose
  class ICal
    # DTSTART;TZID=US-Eastern:19970902T090000
    # RRULE:FREQ=DAILY;INTERVAL=2
    def self.parse(ical)
      new(ical).parse
    end

    def initialize(ical)
      @ical = ical
    end

    def parse
      dtstart, rrule = @ical.split("RRULE:")
      dtstart, exdate = dtstart.split("\n")
      _label, time_string = (dtstart || "").split(";")
      time_zone = parse_timezone(time_string)

      Time.use_zone(time_zone) do
        Hash[
          *parse_dtstart(dtstart) +
            parse_exdate(exdate) +
            parse_rrule(rrule)
          ]
      end
    end

    private

    def parse_timezone(time_string)
      time_zone_rule, _ = (time_string || "").split(":")
      _label, time_zone = (time_zone_rule || "").split("=")
      time_zone
    end

    def parse_dtstart(dtstart)
      return [] unless dtstart.present?

      _label, time_string = dtstart.split(";")
      @starts_at = parse_ical_time(time_string)

      [:starts, @starts_at]
    end

    def parse_ical_time(time_string)
      time_zone = parse_timezone(time_string)

      Montrose::Utils.parse_time(time_string).in_time_zone(time_zone)
    end

    def parse_exdate(exdate)
      return [] unless exdate.present?

      _label, date_string = exdate.split(";")
      @except = Montrose::Utils.as_date(date_string) # only currently supports dates

      [:except, @except]
    end

    def parse_rrule(rrule)
      rrule.gsub(/\s+/, "").split(";").flat_map do |rule|
        prop, value = rule.split("=")
        case prop
        when "FREQ"
          [:every, Montrose::Frequency.from_term(value)]
        when "INTERVAL"
          [:interval, value.to_i]
        when "COUNT"
          [:total, value.to_i]
        when "UNTIL"
          [:until, parse_ical_time(value)]
        when "BYMINUTE"
          [:minute, Montrose::Minute.parse(value)]
        when "BYHOUR"
          [:hour, Montrose::Hour.parse(value)]
        when "BYMONTH"
          [:month, Montrose::Month.parse(value)]
        when "BYDAY"
          [:day, Montrose::Day.parse(value)]
        when "BYMONTHDAY"
          [:mday, Montrose::MonthDay.parse(value)]
        when "BYYEARDAY"
          [:yday, Montrose::YearDay.parse(value)]
        when "BYWEEKNO"
          [:week, Montrose::Week.parse(value)]
        when "WKST"
          [:week_start, value]
        when "BYSETPOS"
          warn "BYSETPOS not currently supported!"
        else
          raise "Unrecognized rrule '#{rule}'"
        end
      end
    end
  end
end
