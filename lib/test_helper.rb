  module Abt
    module Performance
      def assert_performance(time)
        start_time = Time.now
        yield
        execution_time = Time.now - start_time
        assert execution_time < time, "Execution time too big #{execution_time.round(2)}, should be #{time}"
      end
    end
  end