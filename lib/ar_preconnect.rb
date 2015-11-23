class ActiveRecord::ConnectionAdapters::ConnectionPool

  def preconnect!
    (size - 1)
      .times
      .map { checkout }
      .each { |c| checkin(c) }
  end
end
