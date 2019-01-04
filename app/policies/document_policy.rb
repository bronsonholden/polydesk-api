class DocumentPolicy < ApplicationPolicy
  attr_reader :user, :document

  def initialize(auth, document)
    super
    @document = document
  end

  def create?
    return true if super
    @account_user.permissions.find_by code: :document_create
  end

  def show?
    return true if super
    @account_user.permissions.find_by code: :document_show
  end

  def index?
    return true if super
    @account_user.permissions.find_by code: :document_index
  end
end
