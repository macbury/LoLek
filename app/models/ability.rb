class Ability
  include CanCan::Ability
    
  def initialize(user)
    user ||= User.new
    can :read, Link
    can :create, Link
    can :like, Link
    if user.admin?
      can :manage, :all
      can :read, :stats
    else  
      if user.moderator?
        can :destroy, Link
      end
    end
  end
end