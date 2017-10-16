# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username,
            presence: true,
            uniqueness: {
                case_sensitive: false
            }
  validate :validate_username
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, multiline: true

  attr_accessor :login
  has_many :calculations

  # Courtesy of official Devise guide
  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      conditions[:email].downcase! if conditions[:email]
      where(conditions.to_hash).first
    end
  end

  private

    def validate_username
      # This actually doesn't load all records as it may seem and produces the following SQL query
      #   User Exists (47.2ms)  SELECT  1 AS one FROM "users" WHERE "users"."email" = $1 LIMIT $2  [["email", "username"], ["LIMIT", 1]]

      # But for ease of mind this could be rewritten to
      # User.exists?(email: username)
      # But it essentially produces the same querys

      if User.where(email: username).exists?
        errors.add(:username, :invalid)
      end
    end
end
