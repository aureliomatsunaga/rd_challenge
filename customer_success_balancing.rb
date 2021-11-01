# Class responsible for balancing customers between Customer Success using their score as criteria for distribution
# Receives as parameters three arrays, first of customer success, second of customers, and third of away customer success IDs
class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
    @available_customer_success = available_customer_success_sorted_by_score
  end

  # Returns the ID of the customer success with most customers
  def execute
    sorted_customer_success = customer_success_by_customers_count
    return 0 if sorted_customer_success[0][:customers_count] == sorted_customer_success[1][:customers_count]

    sorted_customer_success[0][:id]
  end

  private

  def available_customer_success_sorted_by_score
    @customer_success.reject { |cs| @away_customer_success.include?(cs[:id]) }.sort { |a, b| b[:score] <=> a[:score] }
  end

  def customer_success_by_customers_count
    customer_success_with_customers_count.sort { |a, b| b[:customers_count] <=> a[:customers_count] }
  end

  def customer_success_with_customers_count
    @available_customer_success.each_with_index.map do |acs, idx|
      minimum_score = minimum_score_for_customer_success(acs, idx)
      served_customers = @customers.select { |c| c[:score] <= acs[:score] && c[:score] >= minimum_score }
      { id: acs[:id], customers_count: served_customers.length }
    end
  end

  def minimum_score_for_customer_success(customer_success, index)
    return 0 if customer_success == @available_customer_success.last

    @available_customer_success[index + 1][:score]
  end
end
