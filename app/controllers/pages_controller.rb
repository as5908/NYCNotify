class PagesController < ApplicationController

  def home
    @title = "Home"
  end

  def register
    @title = "Register"
  end

  def deregister
    @title = "De-Register"
  end

  def contact
    @title = "Contact"
  end

  def about
    @title = "About"
  end

  def help
    @title = "Help"
  end
  
  def goodbye
    @title = "Good Bye"
  end

end
