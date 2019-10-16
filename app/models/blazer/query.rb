module Blazer
  class Query < Record
    serialize :assignee_ids, Array
    serialize :team_ids, Array

    belongs_to :creator, Blazer::BELONGS_TO_OPTIONAL.merge(class_name: Blazer.user_class.to_s) if Blazer.user_class
    has_many :checks, dependent: :destroy
    has_many :dashboard_queries, dependent: :destroy
    has_many :dashboards, through: :dashboard_queries
    has_many :audits

    before_validation :statement_format
    validates :statement, presence: true

    scope :named, -> { where("blazer_queries.name <> ''") }

    def to_param
      [id, name].compact.join("-").gsub("'", "").parameterize
    end

    def friendly_name
      name.to_s.sub(/\A[#\*]/, "").gsub(/\[.+\]/, "").strip
    end

    def viewable?(user)
      if Blazer.query_viewable
        Blazer.query_viewable.call(self, user)
      else
        true
      end
    end

    def editable?(user)
      editable = !persisted? || (name.present? && name.first != "*" && name.first != "#") || user == try(:creator)
      editable &&= viewable?(user)
      editable &&= Blazer.query_editable.call(self, user) if Blazer.query_editable
      editable
    end

    def self.creatable?(user)
      Blazer.query_creatable.call(user) if Blazer.query_creatable
    end

    def variables
      Blazer.extract_vars(statement)
    end

    private

    def statement_format
      self.statement.gsub!(/\n/, '')
    end

  end
end
