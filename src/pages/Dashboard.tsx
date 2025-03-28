import React, { useEffect, useState } from 'react';
import { toast } from 'react-hot-toast';
import { Link } from 'react-router-dom';
import { PlusCircle, Building2, LogOut, Pencil, Trash2, Users } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../context/AuthContext';

interface Lead {
  id: string;
  company_name: string;
  contact_name: string;
  contact_email: string;
  contact_phone: string;
  contact_position: string;
  industry_type: string;
  address: string;
  status: string;
  notes: string;
  created_at: string;
}

const INITIAL_FORM_STATE = {
  company_name: '',
  contact_name: '',
  contact_email: '',
  contact_phone: '',
  contact_position: '',
  industry_type: '',
  address: '',
  notes: '',
};

const STATUS_COLORS = {
  new: 'bg-red-100 text-red-800',
  contacted: 'bg-orange-100 text-orange-800',
  confirmed: 'bg-green-100 text-green-800',
};

export default function Dashboard() {
  const [leads, setLeads] = useState<Lead[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingLead, setEditingLead] = useState<Lead | null>(null);
  const { signOut } = useAuth();

  const [formData, setFormData] = useState(INITIAL_FORM_STATE);

  useEffect(() => {
    fetchLeads();
  }, []);

  useEffect(() => {
    if (editingLead) {
      setFormData({
        company_name: editingLead.company_name,
        contact_name: editingLead.contact_name,
        contact_email: editingLead.contact_email,
        contact_phone: editingLead.contact_phone,
        contact_position: editingLead.contact_position || '',
        industry_type: editingLead.industry_type || '',
        address: editingLead.address || '',
        notes: editingLead.notes || '',
      });
      setShowForm(true);
    }
  }, [editingLead]);

  async function fetchLeads() {
    try {
      const { data, error } = await supabase
        .from('leads')
        .select('*')
        .neq('status', 'confirmed')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setLeads(data || []);
    } catch (error) {
      toast.error('Error fetching leads');
    } finally {
      setLoading(false);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    try {
      if (editingLead) {
        const { error } = await supabase
          .from('leads')
          .update(formData)
          .eq('id', editingLead.id);
        if (error) throw error;
        toast.success('Lead updated successfully');
      } else {
        const { error } = await supabase.from('leads').insert([{ ...formData, status: 'new' }]);
        if (error) throw error;
        toast.success('Lead added successfully');
      }
      setShowForm(false);
      setEditingLead(null);
      setFormData(INITIAL_FORM_STATE);
      fetchLeads();
    } catch (error) {
      toast.error(editingLead ? 'Error updating lead' : 'Error adding lead');
    }
  }

  async function handleDelete(id: string) {
    if (!window.confirm('Are you sure you want to delete this lead?')) return;
    
    try {
      const { error } = await supabase.from('leads').delete().eq('id', id);
      if (error) throw error;
      toast.success('Lead deleted successfully');
      fetchLeads();
    } catch (error) {
      toast.error('Error deleting lead');
    }
  }

  async function updateStatus(id: string, status: string) {
    try {
      const { error } = await supabase
        .from('leads')
        .update({ status })
        .eq('id', id);
      if (error) throw error;
      toast.success('Status updated successfully');
      fetchLeads();
    } catch (error) {
      toast.error('Error updating status');
    }
  }

  const handleLogout = async () => {
    try {
      await signOut();
    } catch (error) {
      toast.error('Error signing out');
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <Building2 className="h-8 w-8 text-blue-600" />
              <h1 className="ml-2 text-xl font-bold text-gray-900">
                Thermal Systems Ltd
              </h1>
            </div>
            <div className="flex items-center space-x-4">
              <Link
                to="/confirmed"
                className="flex items-center text-gray-600 hover:text-gray-900"
              >
                <Users className="h-5 w-5 mr-1" />
                Confirmed Customers
              </Link>
              <button
                onClick={handleLogout}
                className="flex items-center text-gray-600 hover:text-gray-900"
              >
                <LogOut className="h-5 w-5 mr-1" />
                Sign out
              </button>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 py-6 sm:px-0">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-2xl font-bold text-gray-900">Customer Leads</h2>
            <button
              onClick={() => {
                setEditingLead(null);
                setFormData(INITIAL_FORM_STATE);
                setShowForm(!showForm);
              }}
              className="flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
            >
              <PlusCircle className="h-5 w-5 mr-1" />
              Add New Lead
            </button>
          </div>

          {showForm && (
            <div className="mb-8 bg-white shadow rounded-lg p-6">
              <form onSubmit={handleSubmit}>
                <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Company Name
                    </label>
                    <input
                      type="text"
                      required
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
                      value={formData.company_name}
                      onChange={(e) =>
                        setFormData({ ...formData, company_name: e.target.value })
                      }
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Contact Name
                    </label>
                    <input
                      type="text"
                      required
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
                      value={formData.contact_name}
                      onChange={(e) =>
                        setFormData({ ...formData, contact_name: e.target.value })
                      }
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Contact Position
                    </label>
                    <input
                      type="text"
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
                      value={formData.contact_position}
                      onChange={(e) =>
                        setFormData({ ...formData, contact_position: e.target.value })
                      }
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Industry Type
                    </label>
                    <input
                      type="text"
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
                      value={formData.industry_type}
                      onChange={(e) =>
                        setFormData({ ...formData, industry_type: e.target.value })
                      }
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Email
                    </label>
                    <input
                      type="email"
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
                      value={formData.contact_email}
                      onChange={(e) =>
                        setFormData({ ...formData, contact_email: e.target.value })
                      }
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700">
                      Phone
                    </label>
                    <input
                      type="tel"
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
                      value={formData.contact_phone}
                      onChange={(e) =>
                        setFormData({ ...formData, contact_phone: e.target.value })
                      }
                    />
                  </div>
                  <div className="sm:col-span-2">
                    <label className="block text-sm font-medium text-gray-700">
                      Address
                    </label>
                    <textarea
                      rows={2}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
                      value={formData.address}
                      onChange={(e) =>
                        setFormData({ ...formData, address: e.target.value })
                      }
                    />
                  </div>
                  <div className="sm:col-span-2">
                    <label className="block text-sm font-medium text-gray-700">
                      Notes
                    </label>
                    <textarea
                      rows={3}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
                      value={formData.notes}
                      onChange={(e) =>
                        setFormData({ ...formData, notes: e.target.value })
                      }
                    />
                  </div>
                </div>
                <div className="mt-4 flex justify-end">
                  <button
                    type="button"
                    onClick={() => {
                      setShowForm(false);
                      setEditingLead(null);
                      setFormData(INITIAL_FORM_STATE);
                    }}
                    className="mr-3 px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
                  >
                    {editingLead ? 'Update Lead' : 'Save Lead'}
                  </button>
                </div>
              </form>
            </div>
          )}

          {loading ? (
            <div className="text-center py-12">Loading...</div>
          ) : leads.length === 0 ? (
            <div className="text-center py-12 text-gray-500">
              No leads found. Add your first lead to get started!
            </div>
          ) : (
            <div className="bg-white shadow overflow-hidden sm:rounded-md">
              <ul className="divide-y divide-gray-200">
                {leads.map((lead) => (
                  <li key={lead.id} className="px-6 py-4 hover:bg-gray-50">
                    <div className="flex items-center justify-between">
                      <div className="flex-grow">
                        <div className="flex items-center justify-between">
                          <h3 className="text-lg font-medium text-gray-900">
                            {lead.company_name}
                          </h3>
                          <div className="flex items-center space-x-2">
                            <button
                              onClick={() => setEditingLead(lead)}
                              className="text-gray-400 hover:text-blue-500"
                            >
                              <Pencil className="h-5 w-5" />
                            </button>
                            <button
                              onClick={() => handleDelete(lead.id)}
                              className="text-gray-400 hover:text-red-500"
                            >
                              <Trash2 className="h-5 w-5" />
                            </button>
                          </div>
                        </div>
                        <p className="text-sm text-gray-500">
                          Contact: {lead.contact_name}
                          {lead.contact_position && ` - ${lead.contact_position}`}
                        </p>
                        <p className="text-sm text-gray-500">
                          Email: {lead.contact_email} • Phone: {lead.contact_phone}
                        </p>
                        {lead.industry_type && (
                          <p className="text-sm text-gray-500">
                            Industry: {lead.industry_type}
                          </p>
                        )}
                        {lead.address && (
                          <p className="text-sm text-gray-500">
                            Address: {lead.address}
                          </p>
                        )}
                        {lead.notes && (
                          <p className="mt-1 text-sm text-gray-600">
                            {lead.notes}
                          </p>
                        )}
                        <div className="mt-2 flex space-x-2">
                          <button
                            onClick={() => updateStatus(lead.id, 'new')}
                            className={`px-3 py-1 rounded-full text-xs font-medium ${
                              lead.status === 'new'
                                ? 'bg-red-100 text-red-800'
                                : 'bg-gray-100 text-gray-800'
                            }`}
                          >
                            New Lead
                          </button>
                          <button
                            onClick={() => updateStatus(lead.id, 'contacted')}
                            className={`px-3 py-1 rounded-full text-xs font-medium ${
                              lead.status === 'contacted'
                                ? 'bg-orange-100 text-orange-800'
                                : 'bg-gray-100 text-gray-800'
                            }`}
                          >
                            Contacted
                          </button>
                          <button
                            onClick={() => updateStatus(lead.id, 'confirmed')}
                            className={`px-3 py-1 rounded-full text-xs font-medium ${
                              lead.status === 'confirmed'
                                ? 'bg-green-100 text-green-800'
                                : 'bg-gray-100 text-gray-800'
                            }`}
                          >
                            Confirm Order
                          </button>
                        </div>
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}