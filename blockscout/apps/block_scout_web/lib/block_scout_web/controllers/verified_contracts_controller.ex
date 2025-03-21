defmodule BlockScoutWeb.VerifiedContractsController do
  use BlockScoutWeb, :controller

  import BlockScoutWeb.Chain,
    only: [paging_options: 1, next_page_params: 3, split_list_by_page: 1, fetch_page_number: 1]

  import BlockScoutWeb.PagingHelper, only: [current_filter: 1, search_query: 1]

  alias BlockScoutWeb.{Controller, VerifiedContractsView}
  alias Explorer.Chain
  alias Explorer.Chain.SmartContract
  alias Phoenix.View

  @necessity_by_association %{
    [address: :token] => :optional,
    address: :required
  }

  def index(conn, %{"type" => "JSON"} = params) do
    full_options =
      [necessity_by_association: @necessity_by_association]
      |> Keyword.merge(paging_options(params))
      |> Keyword.merge(current_filter(params))
      |> Keyword.merge(search_query(params))

    verified_contracts_plus_one = SmartContract.verified_contracts(full_options)
    {verified_contracts, next_page} = split_list_by_page(verified_contracts_plus_one)

    items =
      for contract <- verified_contracts do
        View.render_to_string(VerifiedContractsView, "_contract.html",
          contract: contract,
          token: contract.address.token
        )
      end

    next_page_path =
      case next_page_params(next_page, verified_contracts, params) do
        nil -> nil
        next_page_params -> verified_contracts_path(conn, :index, Map.delete(next_page_params, "type"))
      end

    json(conn, %{items: items, next_page_path: next_page_path})
  end

  def index(conn, params) do
    render(conn, "index.html",
      current_path: Controller.current_full_path(conn),
      filter: params["filter"],
      page_number: params |> fetch_page_number() |> Integer.to_string(),
      contracts_count: Chain.count_contracts_from_cache(),
      verified_contracts_count: Chain.count_verified_contracts_from_cache(),
      new_contracts_count: Chain.count_new_contracts_from_cache(),
      new_verified_contracts_count: Chain.count_new_verified_contracts_from_cache()
    )
  end
end
