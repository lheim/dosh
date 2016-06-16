module ApplicationHelper

  def flash_type(msg)
    return case msg
    when "notice" then "alert-info"
    when "error" then "alert-danger"
    when "alert" then "alert-warning"
    when "success" then "alert-success"
    else "Invalid"
    end
  end



end
