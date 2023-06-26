module Blazer
  class ChecksController < BaseController
    before_action :set_check, only: [:edit, :update, :destroy, :run]
    before_action :set_new_check, only: [:new]

    def index
      state_order = [nil, "disabled", "error", "timed out", "failing", "passing"]
      @checks = Blazer::Check.joins(:query).includes(:query).order("blazer_queries.name, blazer_checks.id").to_a.sort_by { |q| state_order.index(q.state) || 99 }
      @checks.select! { |c| "#{c.query.name} #{c.emails}".downcase.include?(params[:q]) } if params[:q]
    end

    def new
    end

    def create
      @check = Blazer::Check.new(check_params)
      # use creator_id instead of creator
      # since we setup association without checking if column exists
      @check.creator = blazer_user if @check.respond_to?(:creator_id=) && blazer_user

      if @check.save
        redirect_to query_path(@check.query)
      else
        render_errors @check
      end
    end

    def update
      if @check.update(check_params)
        redirect_to query_path(@check.query)
      else
        render_errors @check
      end
    end

    def destroy
      @check.destroy
      redirect_to checks_path
    end

    def run
      @query = @check.query
      redirect_to query_path(@query)
    end

    private

      def check_params
        params.require(:check).permit(:query_id, :emails, :slack_channels, :invert, :check_type, :schedule, slack_members: [])
      end

      def set_check
        @check = Blazer::Check.find(params[:id])
      end

      def set_new_check
        @check = Blazer::Check.new(query_id: params[:query_id])
      end

      helper_method :slack_mentions
      def slack_mentions
        existed_members = @check&.slack_members.presence || []
        @slack_mentions ||= get_slack_mentions + existed_members.each_with_object([]) { |m, list| list << [m, m] if m.present? }
      ensure
        @slack_mentions ||= []
      end

      def get_slack_mentions
        return [] unless Blazer.settings.key?('slack_mentions')
        Blazer::RunStatement.new.perform(Blazer.data_sources[@check.query&.data_source], Blazer.settings['slack_mentions'], {}).rows.map do |row|
          [row.last, "[#{row.first}] #{row.second} - ##{row.last}"]
        end
      rescue
        []
      end
  end
end
