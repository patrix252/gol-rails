class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, :validatable, :trackable
end
