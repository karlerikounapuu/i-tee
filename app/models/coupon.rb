class Coupon < ActiveRecord::Base
  belongs_to :lab
  belongs_to :user # An author of the lab
  has_many :redeems
  has_many :lab_users
  #field :name, :usage, :redeemcode, :retention, :valid_from, :valid_through
  validates_presence_of :name, :redeemcode, :retention, :valid_from, :valid_through, :lab, :user
  validates :redeemcode, :name, :uniqueness => {:case_sensitive => false}
  validates :retention, :numericality => { :greater_than_or_equal_to => 0 }
   validate :reasonable_timeframe
   # TODO: usage statistics, lab killing mechanism
  
  # Verify that timeframe for redemption is valid
  def redeemable?
    today = Time.now
    if today > valid_from and today < valid_through
      return true
    else
      return false
    end
  end
   def still_valid?
    today = Time.now
    if today > valid_through
      return false
    else
      return true
    end
  end
   # Verify that user doesn't have access to lab yet
  def no_present_access?(user)
    present_lab = LabUser.where(user_id: user.id, lab_id: lab_id)
    if present_lab.present?
      return false
    else
      return true
    end
  end
   # Make sure that provided timeframe is usable
  def reasonable_timeframe
    if valid_from > valid_through
      errors.add(:valid_through, "date must be later than 'valid from' date")
    end
  end
end
