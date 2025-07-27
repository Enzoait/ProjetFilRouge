const supabase = require("../../supabaseClient");

module.exports = async (req, res) => {
  if (req.method === "GET") {
    const { data, error } = await supabase
      .from("todos")
      .select("*")
      .order("created_at");
    if (error) return res.status(500).json({ error: error.message });
    return res.status(200).json(data);
  }

  if (req.method === "POST") {
    const todo = req.body;
    const { data, error } = await supabase
      .from("todos")
      .insert([todo])
      .single();
    if (error) return res.status(500).json({ error: error.message });
    return res.status(201).json(data);
  }

  res.status(405).send("Method Not Allowed");
};
