require "net/http"
require "json"
require "ostruct"


class ApiConsultant
  API_URL = "https://statusinvest.com.br/category/advancedsearchresultpaginated"

  OPEN_TIMEOUT = 60 # segundos
  READ_TIMEOUT = 60 # segundos
  MAX_RETRIES = 3


  def initialize(params = {})
    @params = params
  end

  def call
    retries = 0

    begin
      Rails.logger.info("[ApiConsultant] Iniciando chamada à API StatusInvest")
      response = fetch_data
    rescue StandardError => e
      Rails.logger.error("[ApiConsultant] Erro de conexão (tentativa #{retries + 1}/#{MAX_RETRIES}): #{e.class} - #{e.message}")
      retries += 1
      retry if retries < MAX_RETRIES
      Rails.logger.error("[ApiConsultant] Falha definitiva ao chamar a API, retornando nil")
      return nil
    end

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("[ApiConsultant] Resposta não-sucecsso da API: #{response.code} #{response.message}")
      return nil
    end

    data = parse_json(response.body)

    if data.nil? || data.empty?
      Rails.logger.warn("[ApiConsultant] Corpo da resposta vazio ou inválido")
      return nil
    end

    result = process_data(data)
    Rails.logger.info("[ApiConsultant] Chamada concluída com sucesso. Registros retornados: #{result.size}")
    result
  end

  private

  def fetch_data
    query_string = "search=%7B%22Sector%22%3A%22%22%2C%22SubSector%22%3A%22%22%2C%22Segment%22%3A%22%22%2C%22my_range%22%3A%22-20%3B100%22%2C%22forecast%22%3A%7B%22upsidedownside%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22estimatesnumber%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22revisedup%22%3Atrue%2C%22reviseddown%22%3Atrue%2C%22consensus%22%3A%5B%5D%7D%2C%22dy%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22p_l%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22peg_ratio%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22p_vp%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22p_ativo%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22margembruta%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22margemebit%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22margemliquida%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22p_ebit%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22ev_ebit%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22dividaliquidaebit%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22dividaliquidapatrimonioliquido%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22p_sr%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22p_capitalgiro%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22p_ativocirculante%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22roe%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22roic%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22roa%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22liquidezcorrente%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22pl_ativo%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22passivo_ativo%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22giroativos%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22receitas_cagr5%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22lucros_cagr5%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22liquidezmediadiaria%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22vpa%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22lpa%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%2C%22valormercado%22%3A%7B%22Item1%22%3Anull%2C%22Item2%22%3Anull%7D%7D&orderColumn=&isAsc=&page=0&take=617&CategoryType=1"

    uri = URI(API_URL)
    uri.query = query_string

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.open_timeout = OPEN_TIMEOUT
    http.read_timeout = READ_TIMEOUT

    request = Net::HTTP::Get.new(uri)
    request["accept"] = "application/json, text/javascript, */*; q=0.01"
    request["accept-language"] = "pt-BR,pt;q=0.9"
    request["user-agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36"
    request["x-requested-with"] = "XMLHttpRequest"

    http.request(request)
  end

  def parse_json(body)
    JSON.parse(body, symbolize_names: true)
  rescue JSON::ParserError => e
    Rails.logger.error("[ApiConsultant] Erro ao fazer parse do JSON: #{e.message}")
    {}
  end

  def process_data(data)
    return [] unless data[:list].is_a?(Array)

    data[:list].map do |item|
      item.slice(
        :ticker,
        :price,
        :p_l,
        :liquidezmediadiaria,
        :ev_ebit)
    end
  end
end