# frozen_string_literal: true

require 'uri'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  include DeviseTokenAuth::Concerns::User
  include Polydesk::ActivateUser
  alias_attribute :user_name, :name
  alias_attribute :user_email, :email
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  has_many :account_users
  has_many :accounts, through: :account_users, dependent: :destroy
  belongs_to :default_account, class_name: 'Account'

  before_create :send_confirmation_email, if: -> {
    !Rails.env.test? && User.devise_modules.include?(:confirmable)
  }

  def token_validation_response
    UserSerializer.new(self).serialized_json
  end

  private
    def send_confirmation_email
      self.send_confirmation_instructions
    end
end
