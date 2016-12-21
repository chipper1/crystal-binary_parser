class BinaryParser
  macro array(name, opt)
    {% raise "Must have count and type" unless opt[:type] && opt[:count]  %}
    property! :{{name.id}}
    @{{name.id}} = [] of {{opt[:type]}}

    def _read_{{name.id}}(io : IO)
      {% if opt[:count].is_a?(NumberLiteral) %}
        @{{name.id}} = Array({{opt[:type]}}).new({{opt[:count]}}) do
          io.read_bytes({{opt[:type]}})
        end
      {% elsif opt[:count].id != "eof" %}
        @{{name.id}} = Array({{opt[:type]}}).new(@{{opt[:count].id}}.not_nil!) do
          io.read_bytes({{opt[:type]}})
        end
      {% else %}
        @{{name.id}} = [] of {{opt[:type]}}
        # TODO: support :eof
      {% end %}
    end

    def _write_{{name.id}}(io : IO)
      @{{name.id}}.not_nil!.each do |item|
        io.write_bytes(item)
      end
    end

    def _size_dyn_{{name.id}}
      {% if opt[:type].resolve < BinaryParser %}
        res = @{{name.id}}.reduce(0) do |size, x|
          size + x.bytesize
        end
        res
      {% else %}
        @{{name.id}}.size * sizeof({{opt[:type]}})
      {% end %}
    end
  end
end
