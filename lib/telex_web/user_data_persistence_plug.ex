defmodule Telex.UserDataPersistencePlug do
  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, opts) do
    repo = opts[:repo] || raise("repo is required")
    schema = opts[:schema] || raise("schema is required")
    changeset = Keyword.get(opts, :changeset, :changeset)
    # ... in the future also: field mapping, etc.

    user_data = conn.assigns.telegram_user_data

    user_attrs = %{
      telegram_id: user_data["id"],
      telegram_username: user_data["username"],
      telegram_is_bot: user_data["is_bot"],
      telegram_first_name: user_data["first_name"],
      telegram_last_name: user_data["last_name"],
      telegram_language_code: user_data["language_code"],
      telegram_is_premium: !!user_data["is_premium"]
    }

    case repo.get_by(schema, telegram_id: user_data["id"]) do
      nil ->
        apply(schema, changeset, [struct(schema), user_attrs])
        |> repo.insert!()

      user ->
        apply(schema, changeset, [user, user_attrs])
        |> repo.update!()
    end

    conn
  end
end
