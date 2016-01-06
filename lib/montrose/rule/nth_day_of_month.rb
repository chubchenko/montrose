module Montrose
  module Rule
    class NthDayOfMonth
      include Montrose::Rule

      # Initializes rule
      #
      # @param [Hash] days - valid days of week to month occurrence pairs
      #
      def initialize(days)
        @days = days
      end

      def include?(time)
        @days.key?(time.wday) && matches_day_occurrence?(time)
      end

      private

      def matches_day_occurrence?(time)
        expected_occurrences = @days[time.wday]

        this_occ, total_occ = which_occurrence_in_month(time)

        expected_occurrences.any? { |nth_occ| matches_nth_occurrence?(nth_occ, this_occ, total_occ) }
      end

      def matches_nth_occurrence?(nth_occ, this_occ, total_occ)
        return true if nth_occ == this_occ

        nth_occ < 0 && (total_occ + nth_occ + 1) == this_occ
      end

      # Return the count of the number of times wday appears in the month,
      # and which of those time falls on
      def which_occurrence_in_month(time)
        first_occurrence = ((7 - Time.utc(time.year, time.month, 1).wday) + time.wday) % 7 + 1
        this_weekday_in_month_count = ((Montrose::Utils.days_in_month(time) - first_occurrence + 1) / 7.0).ceil
        nth_occurrence_of_weekday = (time.mday - first_occurrence) / 7 + 1
        [nth_occurrence_of_weekday, this_weekday_in_month_count]
      end
    end
  end
end
