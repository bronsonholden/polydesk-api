class DocumentPolicy < ApplicationPolicy
  attr_reader :user, :document

  def initialize(auth, document)
    super
    @document = document
  end

  def create?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:document_create)
  end

  def show?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:document_show)
  end

  def index?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:document_index)
  end

  def update?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:document_update)
  end

  def destroy?
    allowed = super
    return allowed unless allowed.nil?
    has_permission?(:document_destroy)
  end

  def allowed_attributes_for_create
    [:name]
  end

  def allowed_relationships_for_create
    [:folder]
  end

  def allowed_attributes_for_update
    [:name]
  end

  def allowed_relationships_for_update
    [:folder]
  end
end
