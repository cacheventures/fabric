module Fabric
  class TaxId
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    belongs_to :customer, class_name: 'Fabric::Customer',
      primary_key: :stripe_id

    field :stripe_id, type: String
    field :country, type: String
    field :id_type, type: String
    enumerize :id_type, in: %w(
      ae_trn au_abn au_arn br_cnpj br_cpf ca_bn ca_gst_hst ca_pst_bc ca_pst_mb
      ca_pst_sk ca_qst ch_vat cl_tin es_cif eu_vat gb_vat ge_vat hk_br id_npwp
      il_vat in_gst jp_cn jp_rn kr_brn li_uid mx_rfc my_frp my_itn my_sst no_vat
      nz_gst ru_inn ru_kpp sa_vat sg_gst sg_uen th_vat tw_vat ua_vat us_ein
      za_vat
    )
    field :value, type: String
    field :created, type: Time
    field :verification, type: Hash

    validates_uniqueness_of :stripe_id
    validates_presence_of :stripe_id, :id_type, :value

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(tax_id)
      self.stripe_id = Fabric.stripe_id_for(tax_id)
      self.customer_id = tax_id.customer
      self.country = tax_id.country
      self.id_type = tax_id.type
      self.value = tax_id.value
      self.created = tax_id.created
      self.verification = tax_id.verification.try(:to_hash)
    end
  end
end
