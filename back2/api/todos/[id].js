import supabase from "../../supabaseClient.js";

export default async function handler(req, res) {
  const {
    query: { id },
    method,
    body,
  } = req;

  if (method === "PUT") {
    const { data, error } = await supabase
      .from("todos")
      .update(body)
      .eq("id", id)
      .single();
    if (error) return res.status(500).json({ error: error.message });
    return res.status(200).json(data);
  }

  if (method === "DELETE") {
    const { error } = await supabase.from("todos").delete().eq("id", id);
    if (error) return res.status(500).json({ error: error.message });
    return res.status(204).end();
  }

  res.status(405).send("Method Not Allowed");
}
