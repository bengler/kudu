# A richer mock-checkpoint that can handle different requests differently
class Mockpoint
  def initialize(context)
    @context = context
  end
  def get(url, *args)
    case url
      when /^\/identities\/me/
        @context.identity
      when /^\/identities\/.+\/access_to\/.*/
          DeepStruct.wrap(@context.access_to_response)
      else
        raise ArgumentError, "No pattern for mocked GET to #{url}"
    end
  end
  def post(url, *args)
    case url
      when /^\/callbacks\/allowed/
        DeepStruct.wrap(@context.callback_response)
      else
        raise ArgumentError, "No pattern for mocked POST to #{url}"
    end
  end
end
