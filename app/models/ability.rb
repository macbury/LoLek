class Ability
  include CanCan::Ability
    
  def initialize(user)
    user ||= User.new
    can :read, Link
    can :create, Link

    if user.admin?
      can :manage, :all
    else  
      if user.moderator?
        can :destroy, Link
      end
    end
  end
end