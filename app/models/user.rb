class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    has_secure_password
    has_many :tasks, dependent: :destroy
    validates :name, presence: true
    validates :email, presence: true, uniqueness: true
    validates :password, length: { minimum: 8 }, allow_nil: true
end
