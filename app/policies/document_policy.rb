class DocumentPolicy < ApplicationPolicy
  attr_reader :user, :document

  def initialize(user, document)
    @user = user
    @document = document
  end

  def create?
    true
  end

  def show?
    true
  end

  def index?
    true
  end
end
