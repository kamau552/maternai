# ==================== 3. INTEGRATED FRONTEND (cl) ====================
cl import react;
cl import "@jac-client/utils";

cl {
    # Import React hooks
    let { useState, useEffect } = react;
    
    # Import router utilities
    let {
        Router,
        Routes,
        Route,
        Link,
        Navigate,
        useNavigate,
        jacCall,
        jacLogin,
        jacSignup,
        jacLogout,
        jacIsLoggedIn
    } = require("@jac-client/utils");
    # ===== UTILITY FUNCTIONS =====
    def getCurrentUser() -> any {
        userStr = localStorage.getItem("maternai_user");
        if userStr {
            return JSON.parse(userStr);
        }
        return None;
    }
    
    def isLoggedIn() -> bool {
        return localStorage.getItem("maternai_user") != None;
    }
    
    # ===== GLOBAL STYLES =====
    def GlobalStyles() -> str {
        return """
            <style>
                /* Dark Pink Theme */
                :root {
                    --primary-color: #d81b60;
                    --primary-dark: #ad1457;
                    --primary-light: #f48fb1;
                    --primary-gradient: linear-gradient(135deg, #d81b60 0%, #ad1457 100%);
                    --secondary-color: #8e24aa;
                    --accent-color: #ff4081;
                    --text-dark: #2c3e50;
                    --text-light: #6c757d;
                    --text-white: #ffffff;
                    --bg-light: #f8f9fa;
                    --bg-white: #ffffff;
                    --border-color: #e9ecef;
                    --success-color: #4caf50;
                    --warning-color: #ff9800;
                    --danger-color: #f44336;
                    --info-color: #2196f3;
                    --shadow-sm: 0 2px 4px rgba(0,0,0,0.05);
                    --shadow-md: 0 4px 6px rgba(0,0,0,0.07);
                    --shadow-lg: 0 10px 15px rgba(0,0,0,0.1);
                    --radius-sm: 6px;
                    --radius-md: 10px;
                    --radius-lg: 16px;
                }
                
                * { margin: 0; padding: 0; box-sizing: border-box; }
                
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                    background-color: var(--bg-light);
                    color: var(--text-dark);
                    line-height: 1.6;
                }
                
                .container {
                    max-width: 1200px;
                    margin: 0 auto;
                    padding: 0 20px;
                }
                
                .btn {
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    padding: 10px 20px;
                    border: none;
                    border-radius: var(--radius-md);
                    font-weight: 600;
                    font-size: 14px;
                    cursor: pointer;
                    transition: all 0.3s ease;
                    gap: 8px;
                }
                
                .btn-primary {
                    background: var(--primary-gradient);
                    color: var(--text-white);
                }
                
                .btn-primary:hover {
                    transform: translateY(-2px);
                    box-shadow: var(--shadow-lg);
                }
                
                .card {
                    background: var(--bg-white);
                    border-radius: var(--radius-md);
                    box-shadow: var(--shadow-md);
                    padding: 24px;
                    margin-bottom: 24px;
                    border: 1px solid var(--border-color);
                }
                
                .alert {
                    padding: 16px 20px;
                    border-radius: var(--radius-md);
                    margin-bottom: 20px;
                    display: flex;
                    align-items: center;
                    gap: 12px;
                }
                
                .alert-success {
                    background: #d4edda;
                    color: #155724;
                    border-left: 4px solid var(--success-color);
                }
                
                .alert-danger {
                    background: #f8d7da;
                    color: #721c24;
                    border-left: 4px solid var(--danger-color);
                }
                
                .form-group { margin-bottom: 20px; }
                
                .form-label {
                    display: block;
                    margin-bottom: 8px;
                    font-weight: 500;
                }
                
                .form-control {
                    width: 100%;
                    padding: 12px 16px;
                    border: 1px solid var(--border-color);
                    border-radius: var(--radius-md);
                    font-size: 14px;
                }
                
                .form-control:focus {
                    outline: none;
                    border-color: var(--primary-color);
                    box-shadow: 0 0 0 3px rgba(216, 27, 96, 0.1);
                }
                
                .spinner {
                    width: 40px;
                    height: 40px;
                    border: 3px solid rgba(216, 27, 96, 0.1);
                    border-radius: 50%;
                    border-top-color: var(--primary-color);
                    animation: spin 1s ease-in-out infinite;
                    margin: 0 auto;
                }
                
                @keyframes spin {
                    to { transform: rotate(360deg); }
                }
            </style>
        """;
    }
    
    # ===== LOGIN PAGE =====
    def LoginPage() -> any {
        let [email, setEmail] = useState("");
        let [password, setPassword] = useState("");
        let [error, setError] = useState("");
        let [loading, setLoading] = useState(False);

        navigate = useNavigate();

        async def handleLogin(e: any) -> None {
            e.preventDefault();
            setError("");
            setLoading(True);

            result = await jacCall("login_user", {
                "email": email,
                "password": password
            });

            if result and result["success"] {
                localStorage.setItem("maternai_user", JSON.stringify(result["user"]));
                navigate("/dashboard");
            } elif result {
                setError(result["error"]);
            } else {
                setError("Login failed. Please try again.");
            }

            setLoading(False);
        }

        def handleEmailChange(e: any) -> None {
            setEmail(e.target.value);
        }

        def handlePasswordChange(e: any) -> None {
            setPassword(e.target.value);
        }

        return <div style={{"minHeight": "100vh", "display": "flex", "alignItems": "center", "justifyContent": "center", "background": "var(--bg-light)"}}>
            <div className="card" style={{"maxWidth": "400px", "width": "100%"}}>
                <div style={{"textAlign": "center", "marginBottom": "24px"}}>
                    <h2>Welcome to MaternAI</h2>
                    <p style={{"color": "var(--text-light)"}}>Sign in to your account</p>
                </div>

                {error != "" and <div className="alert alert-danger">{error}</div>}

                <form onSubmit={handleLogin}>
                    <div className="form-group">
                        <label className="form-label">Email</label>
                        <input 
                            type="email" 
                            className="form-control" 
                            value={email} 
                            onChange={handleEmailChange} 
                            required 
                        />
                    </div>

                    <div className="form-group">
                        <label className="form-label">Password</label>
                        <input 
                            type="password" 
                            className="form-control" 
                            value={password} 
                            onChange={handlePasswordChange} 
                            required 
                        />
                    </div>

                    <button type="submit" className="btn btn-primary" style={{"width": "100%"}} disabled={loading}>
                        {loading and "Signing In..." or "Sign In"}
                    </button>
                </form>

                <div style={{"textAlign": "center", "marginTop": "24px"}}>
                    <p style={{"color": "var(--text-light)"}}>
                        Don't have an account? <Link to="/register" style={{"color": "var(--primary-color)"}}>Register</Link>
                    </p>
                </div>
            </div>
        </div>;
    }
    
    # ===== REGISTER PAGE =====
    def RegisterPage() -> any {
        let [form, setForm] = useState({
            "full_name": "", 
            "email": "", 
            "password": "", 
            "confirm_password": "",
            "user_type": "patient", 
            "age": "", 
            "pregnancy_week": ""
        });
        let [error, setError] = useState("");
        let [success, setSuccess] = useState("");
        let [loading, setLoading] = useState(False);

        navigate = useNavigate();

        def updateForm(field: str, value: any) -> None {
            newForm = {
                "full_name": form["full_name"],
                "email": form["email"],
                "password": form["password"],
                "confirm_password": form["confirm_password"],
                "user_type": form["user_type"],
                "age": form["age"],
                "pregnancy_week": form["pregnancy_week"]
            };
            newForm[field] = value;
            setForm(newForm);
            setError("");
        }

        def redirectToLogin() -> None {
            navigate("/login");
        }

        async def handleRegister(e: any) -> None {
            e.preventDefault();
            setError("");

            if form["password"] != form["confirm_password"] {
                setError("Passwords do not match");
                return;
            }

            setLoading(True);

            result = await jacCall("register_user", {
                "username": form["email"].split("@")[0],
                "email": form["email"],
                "password": form["password"],
                "full_name": form["full_name"],
                "user_type": form["user_type"],
                "age": int(form["age"]) if form["age"] != "" else 0,
                "pregnancy_week": int(form["pregnancy_week"]) if form["pregnancy_week"] != "" else 0
            });

            if result and result["success"] {
                setSuccess("Registration successful! Redirecting to login...");
                setTimeout(redirectToLogin, 2000);
            } elif result {
                setError(result["error"]);
            } else {
                setError("Registration failed");
            }

            setLoading(False);
        }

        return <div style={{"minHeight": "100vh", "display": "flex", "alignItems": "center", "justifyContent": "center", "background": "var(--bg-light)"}}>
            <div className="card" style={{"maxWidth": "500px", "width": "100%"}}>
                <div style={{"textAlign": "center", "marginBottom": "24px"}}>
                    <h2>Create Account</h2>
                    <p style={{"color": "var(--text-light)"}}>Join MaternAI for personalized care</p>
                </div>

                {success != "" and <div className="alert alert-success">{success}</div>}
                {error != "" and <div className="alert alert-danger">{error}</div>}

                <form onSubmit={handleRegister}>
                    <div className="form-group">
                        <label className="form-label">Full Name</label>
                        <input 
                            type="text" 
                            className="form-control" 
                            value={form["full_name"]} 
                            onChange={lambda e: any -> None { updateForm("full_name", e.target.value); }}
                            required 
                        />
                    </div>

                    <div className="form-group">
                        <label className="form-label">Email</label>
                        <input 
                            type="email" 
                            className="form-control" 
                            value={form["email"]} 
                            onChange={lambda e: any -> None { updateForm("full_name", e.target.value); }} 
                            required 
                        />
                    </div>

                    <div className="form-group">
                        <label className="form-label">Password</label>
                        <input 
                            type="password" 
                            className="form-control" 
                            value={form["password"]} 
                            onChange={lambda e: any -> None { updateForm("password", e.target.value); }} 
                            required 
                        />
                    </div>

                    <div className="form-group">
                        <label className="form-label">Confirm Password</label>
                        <input 
                            type="password" 
                            className="form-control" 
                            value={form["confirm_password"]} 
                            onChange={lambda e: any -> None { updateForm("password", e.target.value); }}  
                            required 
                        />
                    </div>

                    <div className="form-group">
                        <label className="form-label">User Type</label>
                        <select 
                            className="form-control" 
                            value={form["user_type"]} 
                            onChange={lambda e: any -> None { updateForm("user_type", e.target.value); }} 
                        >
                            <option value="patient">Expecting Mother</option>
                            <option value="doctor">Healthcare Provider</option>
                        </select>
                    </div>

                    {form["user_type"] == "patient" and 
                        <div>
                            <div className="form-group">
                                <label className="form-label">Age</label>
                                <input 
                                    type="number" 
                                    className="form-control" 
                                    value={form["age"]} 
                                    onChange={lambda e: any -> None { updateForm("age", e.target.value); }} 
                                    required 
                                />
                            </div>

                            <div className="form-group">
                                <label className="form-label">Pregnancy Week</label>
                                <input 
                                    type="number" 
                                    className="form-control" 
                                    value={form["pregnancy_week"]} 
                                    onChange={lambda e: any -> None { updateForm("pregnancy_week", e.target.value); }} 
                                    required 
                                />
                            </div>
                        </div>
                    }

                    <button type="submit" className="btn btn-primary" style={{"width": "100%"}} disabled={loading}>
                        {loading and "Creating Account..." or "Create Account"}
                    </button>
                </form>

                <div style={{"textAlign": "center", "marginTop": "24px"}}>
                    <p style={{"color": "var(--text-light)"}}>
                        Already have an account? <Link to="/login" style={{"color": "var(--primary-color)"}}>Sign In</Link>
                    </p>
                </div>
            </div>
        </div>;
    }
    
    # ===== NAVBAR =====
    def NavBar() -> any {
        let [loggedIn, setLoggedIn] = useState(False);
        let [user, setUser] = useState(None);
        
        def checkLoginStatus() -> None {
            userStr = localStorage.getItem("maternai_user");
            if userStr {
                userData = JSON.parse(userStr);
                setUser(userData);
                setLoggedIn(True);
            } else {
                setLoggedIn(False);
            }
        }
        
        useEffect(lambda -> None { checkLoginStatus(); }, []);
        
        def handleLogout() -> None {
            localStorage.removeItem("maternai_user");
            window.location.href = "/login";
        }
        
        return <nav style={{"background": "var(--primary-gradient)", "padding": "16px 0", "boxShadow": "var(--shadow-md)"}}>
            <div className="container" style={{"display": "flex", "justifyContent": "space-between", "alignItems": "center"}}>
                <Link to="/" style={{"textDecoration": "none", "display": "flex", "alignItems": "center", "gap": "12px", "color": "white"}}>
                    <h1 style={{"margin": "0", "fontSize": "20px", "fontWeight": "700"}}>MaternAI</h1>
                </Link>
                
                <div style={{"display": "flex", "gap": "16px", "alignItems": "center"}}>
                    {loggedIn and
                        <div style={{"display": "flex", "gap": "16px", "alignItems": "center"}}>
                            <Link to="/dashboard" style={{"color": "white", "textDecoration": "none", "fontWeight": "500"}}>Dashboard</Link>
                            <Link to="/facilities" style={{"color": "white", "textDecoration": "none", "fontWeight": "500"}}>Hospitals</Link>
                            <Link to="/care-tips" style={{"color": "white", "textDecoration": "none", "fontWeight": "500"}}>Care Tips</Link>
                            <div style={{"display": "flex", "alignItems": "center", "gap": "8px", "color": "white"}}>
                                <span>{user and user["full_name"] or "User"}</span>
                            </div>
                            <button onClick={handleLogout} className="btn" style={{"background": "rgba(255,255,255,0.2)", "color": "white", "padding": "8px 16px"}}>
                                Logout
                            </button>
                        </div>
                    }
                    {not loggedIn and
                        <div style={{"display": "flex", "gap": "12px"}}>
                            <Link to="/login" className="btn" style={{"background": "rgba(255,255,255,0.2)", "color": "white"}}>Login</Link>
                            <Link to="/register" className="btn" style={{"background": "white", "color": "var(--primary-color)"}}>Register</Link>
                        </div>
                    }
                </div>
            </div>
        </nav>;
    }
    
    # ===== DASHBOARD =====
    def DashboardPage() -> any {
        let [user, setUser] = useState(None);
        let [data, setData] = useState(None);
        let [loading, setLoading] = useState(True);
        
        def checkAuth() -> None {
            userStr = localStorage.getItem("maternai_user");
            if userStr {
                userData = JSON.parse(userStr);
                setUser(userData);
            }
        }
        
       useEffect(lambda -> None { checkAuth(); }, []);
        
        async def loadData() -> None {
            if not user {
                return;
            }
            
            setLoading(True);
            result = await jacCall("get_dashboard_data", {
                "user_id": user["id"]
            });
            
            if result {
                setData(result);
            }
            setLoading(False);
        }
        
       useEffect(lambda -> None { 
          if user {
            loadData();
         }
         }, [user]);

        if not user {
            return <Navigate to="/login" />;
        }
        
        if loading {
            return <div className="container" style={{"padding": "40px 20px", "textAlign": "center"}}>
                <div className="spinner"></div>
                <p style={{"marginTop": "16px", "color": "var(--text-light)"}}>Loading dashboard...</p>
            </div>;
        }
        
        if not data {
            return <div className="container" style={{"padding": "40px 20px"}}>
                <div className="alert alert-danger">Failed to load dashboard data</div>
            </div>;
        }
        
        patient = data.get("patient", {});
        stats = data.get("stats", {});
        appointments = data.get("appointments", []);
        
        return <div>
            <div className="container" style={{"padding": "32px 20px"}}>
                <div className="card">
                    <h2>{patient.get("name", "Patient")}</h2>
                    <p>Age: {patient.get("age")} | Week: {patient.get("week")}/40</p>
                </div>
                
                <div style={{"display": "grid", "gridTemplateColumns": "repeat(auto-fit, minmax(200px, 1fr))", "gap": "16px"}}>
                    <div className="card" style={{"textAlign": "center"}}>
                        <h3>{stats.get("total_metrics", 0)}</h3>
                        <p>Health Metrics</p>
                    </div>
                    
                    <div className="card" style={{"textAlign": "center"}}>
                        <h3>{stats.get("abnormal_metrics", 0)}</h3>
                        <p>Abnormal Readings</p>
                    </div>
                    
                    <div className="card" style={{"textAlign": "center"}}>
                        <h3>{stats.get("upcoming_appointments", 0)}</h3>
                        <p>Upcoming Appointments</p>
                    </div>
                </div>
            </div>
        </div>;
    }

    # ===== FACILITIES PAGE =====
    def FacilitiesPage() -> any {
        let [facilities, setFacilities] = useState([]);
        let [loading, setLoading] = useState(True);
        
        async def loadFacilities() -> None {
            setLoading(True);
            mockResult = {
                "success": True,
                "facilities": [
                    {"name": "City Hospital", "type": "Hospital", "address": "123 Main St", "distance": 2.5, "rating": 4.5, "phone": "555-1234"}
                ]
            };
            
            if mockResult["success"] {
                setFacilities(mockResult["facilities"]);
            }
            setLoading(False);
        }
        
        useEffect(lambda -> None { loadFacilities(); }, []);
        
        return <div>
            <div className="container" style={{"padding": "32px 20px"}}>
                <h2>Healthcare Facilities</h2>
                
                {loading and
                    <div style={{"textAlign": "center"}}>
                        <div className="spinner"></div>
                        <p>Loading facilities...</p>
                    </div>
                }
                
                {not loading and
                  <div style={{"display": "grid", "gap": "16px"}}>
                    {for facility in facilities {
                      <div className="card" key={facility["name"]}>
                        <h4>{facility["name"]}</h4>
                        <p>{facility["type"]} | {facility["address"]}</p>
                        <p>Distance: {facility["distance"]} km | Rating: {facility["rating"]}</p>
                        <a href={"tel:" + facility["phone"]}>Call {facility["phone"]}</a>
                       </div>
                   }}
                  </div>
              }
            </div>
        </div>;
    }
    
    # ===== CARE TIPS PAGE =====
    def CareTipsPage() -> any {
        let [tips, setTips] = useState([]);
        let [loading, setLoading] = useState(True);
        
        async def loadTips() -> None {
            setLoading(True);
            mockTips = [
                {"id": "1", "title": "Stay Hydrated", "content": "Drink at least 8 glasses of water daily", "trimester": 1, "category": "Nutrition", "icon": "fas fa-water"}
            ];
            setTips(mockTips);
            setLoading(False);
        }
        
        useEffect(() -> None { loadTips(); }, []);
        
        return <div>
            {GlobalStyles()}
            <div className="container" style={{"padding": "32px 20px"}}>
                <h1>Pregnancy Care Tips</h1>
                
                {loading and
                    <div style={{"textAlign": "center"}}>
                        <div className="spinner"></div>
                    </div>
                }
                
                {not loading and
                    <div style={{"display": "grid", "gap": "24px"}}>
                        {tips.map((tip: dict) -> any {
                            return <div className="card" key={tip["id"]}>
                                <h3>{tip["title"]}</h3>
                                <p>{tip["content"]}</p>
                            </div>;
                        })}
                    </div>
                }
            </div>
        </div>;
    }
    
    # ===== HOME PAGE =====
    def HomePage() -> any {
        loggedIn = isLoggedIn();
        dashboardPath = "/dashboard" if loggedIn else "/register";
        buttonText = "Go to Dashboard" if loggedIn else "Get Started";
        
        return <div>
            {GlobalStyles()}
            <section style={{"background": "var(--primary-gradient)", "color": "white", "padding": "80px 0", "textAlign": "center"}}>
                <div className="container">
                    <h1 style={{"fontSize": "48px", "marginBottom": "24px"}}>MaternAI</h1>
                    <p style={{"fontSize": "20px", "marginBottom": "32px"}}>
                        AI-Powered Maternal Health Monitoring Platform
                    </p>
                    <Link to={dashboardPath} className="btn" style={{"background": "white", "color": "var(--primary-color)"}}>
                        {buttonText}
                    </Link>
                </div>
            </section>
        </div>;
    }
    
    # ===== MAIN APP =====
    def App() -> any {
        return <div>
            <NavBar />
            <Routes>
                <Route path="/" element={<HomePage />} />
                <Route path="/login" element={<LoginPage />} />
                <Route path="/register" element={<RegisterPage />} />
                <Route path="/dashboard" element={<DashboardPage />} />
                <Route path="/facilities" element={<FacilitiesPage />} />
                <Route path="/care-tips" element={<CareTipsPage />} />
                <Route path="*" element={<div className="container">
                    <h1>404 - Page Not Found</h1>
                    <Link to="/" className="btn btn-primary">Go Home</Link>
                </div>} />
            </Routes>
        </div>;
    }

    def app() -> any {
        return <Router>
            <App />
        </Router>;
    }
}