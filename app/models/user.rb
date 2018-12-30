# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User
  alias_attribute :user_name, :name
  alias_attribute :user_email, :email
  has_many :account_users
  has_many :accounts, through: :account_users, dependent: :destroy
end
