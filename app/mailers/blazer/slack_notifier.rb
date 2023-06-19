require "net/http"

module Blazer
  class SlackNotifier
    def self.state_change(check, state, state_was, rows_count, error, check_type)
      check.split_slack_channels.each do |channel|
        text =
          if error
            error
          elsif rows_count > 0 && check_type == "bad_data"
            pluralize(rows_count, "row")
          end

        payload = {
          channel: channel,
          attachments: [
            {
              title: escape("Check #{state.titleize}: #{check.query.name}"),
              title_link: query_url(check.query_id),
              text: escape(text),
              color: state == "passing" ? "good" : "danger"
            }
          ]
        }

        post(Blazer.slack_webhook_url, payload)
      end
    end

    def self.failing_checks(channel, checks)
      all_mentions = []
      attachments = checks.map do |check|
        mentions = check.split_slack_members
        all_mentions << mentions
        result = Blazer.data_sources[check.query.data_source].run_statement(check.query.statement)
        {
          mrkdwn_in: %w[title text],
          title: "<#{query_url(check.query_id)}|#{escape(check.query.name)}> #{escape(check.state)} #{mentions.join(' ')}",
          text: "#{Blazer.slack_preview_items_number} first rows `#{result.columns.first}: #{result.rows.first(Blazer.slack_preview_items_number).map(&:first).join(', ')}`",
          color: 'warning'
        }
      end

      payload = {
        channel: channel,
        blocks: [
          {
            type: 'header',
            text: {
              type: 'plain_text',
              text: escape("#{pluralize(checks.size, 'Check')} Failing")
            }
          },
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: "Hey #{all_mentions.join(' ')}, there are some failing checks:"
            }
          }
        ],
        attachments: attachments
      }

      post(Blazer.slack_webhook_url, payload)
    end

    # https://api.slack.com/docs/message-formatting#how_to_escape_characters
    # - Replace the ampersand, &, with &amp;
    # - Replace the less-than sign, < with &lt;
    # - Replace the greater-than sign, > with &gt;
    # That's it. Don't HTML entity-encode the entire message.
    def self.escape(str)
      str.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;") if str
    end

    def self.pluralize(*args)
      ActionController::Base.helpers.pluralize(*args)
    end

    def self.query_url(id)
      Blazer::Engine.routes.url_helpers.query_url(id, host: Blazer.host)
    end

    def self.post(url, payload)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 3
      http.read_timeout = 5
      http.post(uri.request_uri, payload.to_json)
    end
  end
end
