class DocumentPolicy < ApplicationPolicy
  attr_reader :user, :document

  def initialize(auth, document)
    super
    @document = document
  end

  def create?
    allowed = super
    return allowed unless allowed.nil?
    @account_user.permissions.find_by code: :document_create
  end

  def show?
    allowed = super
    return allowed unless allowed.nil?
    @account_user.permissions.find_by code: :document_show
  end

  def index?
    allowed = super
    return allowed unless allowed.nil?
    @account_user.permissions.find_by code: :document_index
  end

  def update?
    allowed = super
    return allowed unless allowed.nil?
    @account_user.permissions.find_by code: :document_update
  end

  def destroy?
    allowed = super
    return allowed unless allowed.nil?
    @account_user.permissions.find_by code: :document_destroy
  end
end
