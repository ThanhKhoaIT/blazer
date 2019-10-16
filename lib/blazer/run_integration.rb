module Blazer
  class RunIntegration

    def initialize(results, integration)
      @results = results
      @integration = integration
    end

    def call
      return if integration.blank?
      eval integration
      return {
        headers: @headers,
        rows: @rows
      }
    end

    private

    attr_reader :results
    attr_reader :integration

  end
end
