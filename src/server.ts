import app from "./app.js";
import { ENV } from "./lib/env.js";

app.listen(ENV.PORT, "0.0.0.0", () => {
  console.log(`Server TeraParent berjalan di http://localhost:${ENV.PORT}`);
});