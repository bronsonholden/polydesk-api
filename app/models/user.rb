# frozen_string_literal: true

require 'uri'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  include DeviseTokenAuth::Concerns::User
  include Polydesk::Activation
  alias_attribute :user_name, :name
  alias_attribute :user_email, :email
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates_confirmation_of :password
  attr_readonly :identifier
  validates :identifier, uniqueness: true,
                         presence: true,
                         length: { minimum: 3, maximum: 20 },
                         format: {
                           with: /\A[a-z0-9][\-a-z0-9]+[a-z0-9]\z/,
                           message: 'may only contain lowercase alphanumerals and -, and must not end with -'
                         }
  validates :account_name, presence: true
  has_many :account_users
  belongs_to :default_account, class_name: 'User', optional: true

  before_create :send_confirmation_email, if: -> {
    #!Rails.env.test? &&
    User.devise_modules.include?(:confirmable)
  }

  def has_password?
    !encrypted_password.empty?
  end

  protected
    def password_required?
      false
    end

  private
    def send_confirmation_email
      self.send_confirmation_instructions
    end
end
