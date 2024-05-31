class Zookeeper
  class Helpers
    def in_hash?(hash, *keys)
      current = hash
      keys.each do |key|
        return false unless current.is_a?(Hash) && current.key?(key)
        current = current[key]
      end
      true
    end
  end
end
