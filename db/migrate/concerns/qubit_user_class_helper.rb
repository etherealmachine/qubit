module QubitUserClassHelper
  def get_user_class_details
    user_class = Qubit.user_class.constantize
    primary_key_type = user_class.columns_hash[user_class.primary_key].type
    [user_class, primary_key_type]
  end
end 