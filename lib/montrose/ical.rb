# frozen_string_literal: true

require "montrose/frequency"

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
      Hash[*parse_dtstart(dtstart) + parse_rrule(rrule)]
    end

    private

    def parse_dtstart(dtstart)
      _label, time_string = dtstart.split(";")
      @starts_at = Montrose::Utils.parse_time(time_string)

      [:starts, @starts_at]
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
          [:until, Montrose::Utils.parse_time(value)]
        when "BYMONTH"
          [:month, value.split(",").compact.map { |m|
            Montrose::Month.number!(m)
          }]
        when "BYDAY"
          [:day, value.split(",").map { |d| Montrose::Day.number!(d) }]
        end
      end
    end
  end
end
