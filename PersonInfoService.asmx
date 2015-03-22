<%@ WebService Language="C#" Class="PersonInfoService" %>

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Text.RegularExpressions;
using Arena.Core;

[WebService(Namespace = "http://localhost/Arena")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
// [System.Web.Script.Services.ScriptService]
public class PersonInfoService  : WebService 
{

    public PersonInfoService()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }
    
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public string[] GetPersonInfo(string user_name, string info)
    {
        var person = new Person(user_name);
        if (person.PersonID < 0)
        {
            return new string[] { "error", "Not a valid person" };
        }

        switch (info.ToLower())
        {
            case "birthdate":
                return new string[] { "birthdate", person.BirthDate.ToShortDateString() };
            case "campus":
                if (person.Campus != null)
                {
                    return new string[] { "campus", person.Campus.Name.ToString() };
                }
                else
                {
                    return new string[] { "campus", "none" };
                }
            case "email":
                return new string[] { "email", person.Emails[0].Email.ToString() };
            case "firstname":
                return new string[] { "firstname", person.FirstName.ToString() };
            case "gender":
                return new string[] { "gender", person.Gender.ToString() };
            case "lastname":
                return new string[] { "lastname", person.LastName.ToString() };
            case "maritalstatus":
                return new string[] { "maritalstatus", person.MaritalStatus.Value.ToString() };
            case "middlename":
                return new string[] { "middlename", person.MiddleName.ToString() };
            case "nickname":
                return new string[] { "nickname", person.NickName.ToString() };
            case "personid":
                return new string[] { "personid", person.PersonID.ToString() };
            case "businessphone":
            case "cellphone":
            case "homephone":
                bool found = false;
                for (int i = 0; i <= person.Phones.Count-1; i++)
                {
                    if (person.Phones[i].PhoneType.Value.ToLower().IndexOf(info.ToString().Substring(0,info.IndexOf("phone"))) != -1 && !found)
                    {
                        return new string[] { info, person.Phones[i].Number.ToString() };
                    }
                }
                if(!found)
                {
                    return new string[] {"error","no "+info+" found"};
                } 
                break;    
            case "streetaddress1":
                return new string[] { "streetaddress1", person.PrimaryAddress.StreetLine1.ToString() };
            case "streetaddress2":
                return new string[] { "streeaddress2", person.PrimaryAddress.StreetLine2.ToString() };
            case "city":
                return new string[] { "city", person.PrimaryAddress.City.ToString() };
            case "state":
                return new string[] { "state", person.PrimaryAddress.State.ToString() };
            case "postalcode":
                return new string[] { "postalcode", person.PrimaryAddress.PostalCode.ToString() };
            case "country":
                return new string[] { "country", person.PrimaryAddress.Country.ToString() };
            case "title":
                return new string[] { "title", person.Title.ToString() };
            case "socialsecurity":
                return new string[] { "socialsecurity", "***-**-"+person.SSN.ToString().Substring(7) };
            case "fullname":
            default:
                return new string[] { "fullname", person.FullName.ToString() };
        }

        return new string[] { "what the heck, this shouldn't happen" };
         
    }


    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public string[] SetPersonInfo(string user_name, string info, string new_value)
    {
        var person = new Person(user_name);
        bool changed = false;
        string errorText = "";
        int intVal = 0;
        DateTime dateVal = new DateTime(1970, 1, 1);
        if (person.PersonID < 0)
        {
            return new string[] { "error", "Not a valid person" };
        }

        switch (info.ToLower())
        {
            case "firstname":
                person.FirstName = new_value.ToString().Substring(0, 1).ToUpper() + new_value.ToString().Substring(1).ToLower();
                changed = true;
                break;
            case "birthdate":
                try
                {
                    dateVal = Convert.ToDateTime(new_value);
                }
                catch (FormatException e)
                {
                    errorText = "Input string doesn't look like a date.";
                }
                if (errorText.Length > 0)
                {
                    return new string[] { "error", errorText };
                }
                person.BirthDate = dateVal;
                changed = true;
                break;
            case "email":
                // lookup all current emails
                bool found = false;
                for (int i = 0; i <= person.Emails.Count-1; i++)
                {
                    if ((person.Emails[i].Email.ToLower() == new_value.ToLower()) && !found)
                    {
                       // if email exists in current list, exit
                       found = true;
                    }
                }
                // if not, add it as an active email address
                if(!found)
                {
                    var perEmail = new PersonEmail();
                    perEmail.Active = true;
                    perEmail.PersonId = person.PersonID;
                    perEmail.CreatedBy = user_name;
                    perEmail.Email = new_value.ToLower();
                    perEmail.Order = 0;
                    person.Emails.Add(perEmail);
                    person.Emails.Save(person.PersonID, ArenaContext.Current.Organization.OrganizationID, ArenaContext.Current.User.Identity.Name);
                    changed = true;
                }
                break;
            case "gender":
                // According to the database 0 = male, 1= female, and 2 = System Administrator
                switch(new_value.ToString().ToLower())
                {
                    case "0": 
                    case "male":
                        person.Gender = Arena.Enums.Gender.Male;
                        changed = true;
                        break;
                    case "1":
                    case "female":
                        person.Gender = Arena.Enums.Gender.Female;
                        changed = true;
                        break;
                    case "2":
                    case "sysadmin":
                        person.Gender = Arena.Enums.Gender.Undefined;
                        changed = true;
                        break;
                    default:
                        person.Gender = Arena.Enums.Gender.Unknown;
                        changed = true;
                        break;   
                }
                break;
            case "lastname":
                person.LastName = new_value.ToString().Substring(0, 1).ToUpper() + new_value.ToString().Substring(1).ToLower();
                changed = true;
                break;
            case "middlename":
                person.MiddleName = new_value.ToString().Substring(0, 1).ToUpper() + new_value.ToString().Substring(1).ToLower();
                changed = true;
                break;
            case "nickname":
                person.NickName = new_value.ToString().Substring(0, 1).ToUpper() + new_value.ToString().Substring(1).ToLower();
                changed = true;
                break;
            case "maritalstatus":
                var marLookup = new LookupCollection(84);
                person.MaritalStatus.LookupID = marLookup.FindByValue(new_value.ToString().Substring(0, 1).ToUpper() + new_value.ToString().Substring(1).ToLower()).LookupID;
                changed = true;
                break;
            case "cellphone":
            case "businessphone":
            case "homephone":
                found = false;
                string phNumber = Regex.Replace(new_value, "[^0-9]", "");
                for (int i = 0; i <= person.Phones.Count-1; i++)
                {
                    if (person.Phones[i].PhoneType.Value.ToLower().IndexOf(info.ToString().Substring(0,info.IndexOf("phone"))) != -1 && !found)
                    {
                        person.Phones[i].Number = phNumber;
                        person.SavePhones(ArenaContext.Current.Organization.OrganizationID, ArenaContext.Current.User.Identity.Name);
                        found = true;
                        changed = true;
                        break;
                    }
                }
                if(!found)
                {
                   var phone = new PersonPhone(person.PersonID,phNumber);
                   changed = true;
                } 
                break;
            case "streetaddress1":
                person.PrimaryAddress.StreetLine1 = new_value;
                person.PrimaryAddress.Save(user_name, true, true);
                changed = true;
                break;
            case "streetaddress2":
                person.PrimaryAddress.StreetLine2 = new_value;
                person.PrimaryAddress.Save(user_name, true, true);
                changed = true;
                break;
            case "city":
                person.PrimaryAddress.City = new_value;
                person.PrimaryAddress.Save(user_name, true, true);
                changed = true;
                break;
            case "state":
                person.PrimaryAddress.State = new_value;
                person.PrimaryAddress.Save(user_name, true, true);
                changed = true;
                break;
            case "postalcode":
                person.PrimaryAddress.PostalCode = new_value;
                person.PrimaryAddress.Save(user_name, true, true);
                changed = true;
                break;
            case "country":
                person.PrimaryAddress.Country = new_value;
                person.PrimaryAddress.Save(user_name, true, true);
                changed = true;
                break;
            case "title":
                var titLookup = new LookupCollection(40);
                person.Title.LookupID = titLookup.FindByValue(new_value.ToString().Substring(0, 1).ToUpper() + new_value.ToString().Substring(1).ToLower()).LookupID;
                changed = true;
                break;
            case "socialsecurity":
                string ssn = Regex.Replace(new_value, "[^0-9]", "").Substring(0,3) + "-" + Regex.Replace(new_value, "[^0-9]", "").Substring(3,2) + "-" + Regex.Replace(new_value, "[^0-9]", "").Substring(5);
                if (ssn.Length == 11)
                {
                    person.SSN = ssn;
                    changed = true;
                }
                break;
            case "campus":
               // Campus not implemented because we don't need it for this implementations, and it's not obvious how to set the correct lookup value. Also values could change from implementation to implementation...
                
            default:
                return new string[] { "not sure what you wanted me to update, but I got confused and didn't update anything...I only speak one langauage" };
        }

        if (changed)
        {
            person.Save(ArenaContext.Current.Organization.OrganizationID, ArenaContext.Current.User.Identity.Name, true);
            return new string[] { "Updated " + info + " for " + person.NickName + "." };
        }

        return new string[] { "No Changes needed..." };
    }
}