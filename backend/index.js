import express from "express";
import cors from "cors";

const app = express();
app.use(cors());

app.get("/todos", (req, res) => {
  res.json([
    { id: "1", text: "test 1" },
    { id: "2", text: "test 2" },
  ]);
});

app.listen(3005, () => {
  console.log(`Server is running`);
});
