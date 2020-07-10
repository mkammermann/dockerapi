module Docker
    module API
        class Exec < Docker::API::Base

            #################################################
            # Items in this area to be removed before 1.0.0 #
            #################################################
            def inspect *args
                return super.inspect if args.size == 0
                warn  "WARNING: #inspect is deprecated and will be removed in the future, please use #details instead."
                name = args[0]
                details(name)
            end
            #################################################

            def create name, body = {}
                validate Docker::API::InvalidRequestBody, [:AttachStdin, :AttachStdout, :AttachStderr, :DetachKeys, :Tty, :Env, :Cmd, :Privileged, :User, :WorkingDir], body
                @connection.request(method: :post, path: "/containers/#{name}/exec", headers: {"Content-Type": "application/json"}, body: body.to_json )
            end

            def start name, body = {}
                validate Docker::API::InvalidRequestBody, [:Detach, :Tty], body

                stream = ""
                response = @connection.request(method: :post, 
                    path: "/exec/#{name}/start", 
                    headers: {"Content-Type": "application/json"},  
                    body: body.to_json, 
                    response_block: lambda { |chunk, remaining_bytes, total_bytes| stream += chunk.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?') }
                )
                response.data.merge!({stream: stream})
                response
            end

            def resize name, params = {}
                validate Docker::API::InvalidParameter, [:w, :h], params
                @connection.post(build_path("/exec/#{name}/resize", params))
            end

            def details name
                @connection.get("/exec/#{name}/json")
            end

        end
    end
end