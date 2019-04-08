class ReportSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :created_at, :updated_at

  link :self, -> (report) {
    report.url
  }
end
